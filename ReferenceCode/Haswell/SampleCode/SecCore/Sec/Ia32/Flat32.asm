;
; This file contains a 'Sample Driver' and is licensed as such  
; under the terms of your license agreement with Intel or your  
; vendor.  This file may be modified by the user, subject to    
; the additional terms of the license agreement 
;
;------------------------------------------------------------------------------
;
; Copyright (c) 1999 - 2013, Intel Corporation. All rights reserved.<BR>
; This software and associated documentation (if any) is furnished
; under a license and may only be used or copied in accordance
; with the terms of the license. Except as permitted by such
; license, no part of this software or documentation may be
; reproduced, stored in a retrieval system, or transmitted in any
; form or by any means without the express written consent of
; Intel Corporation.
;
; Module Name:
;
;  Flat32.asm
;
; Abstract:
;
;  This is the code that goes from real-mode to protected mode.
;  It consumes the reset vector.
;
;------------------------------------------------------------------------------
  INCLUDE Platform.inc
  INCLUDE Ia32.inc
  INCLUDE Chipset.inc
  INCLUDE SecCore.inc

.686p
.xmm
.model small, c

EXTRN   SecStartup:NEAR

; ECP porting
EXTRN   PcdGet32 (PcdFlashMicrocodeFvBase):DWORD
EXTRN   PcdGet32 (PcdFlashMicrocodeFvSize):DWORD
EXTRN   PcdGet32 (PcdNemCodeCacheSize):DWORD
EXTRN   PcdGet32 (PcdNemCodeCacheBase):DWORD
EXTRN   PcdGet32 (PcdFlashAreaBaseAddress):DWORD
EXTRN   PcdGet32 (PcdTemporaryRamBase):DWORD
EXTRN   PcdGet32 (PcdTemporaryRamSize):DWORD
EXTRN   PcdGet64 (PcdPciExpressBaseAddress):QWORD

_TEXT_REALMODE      SEGMENT PARA PUBLIC USE16 'CODE'
                    ASSUME  CS:_TEXT_REALMODE, DS:_TEXT_REALMODE

;------------------------------------------------------------------------------
;
;  SEC "Security" Code module.
;
;  Transition to non-paged flat-model protected mode from a
;  hard-coded GDT that provides exactly two descriptors.
;  This is a bare bones transition to protected mode only
;  used for while in PEI and possibly DXE.
;
;  IA32 specific cache as RAM modules
;
;  After enabling protected mode, a far jump is executed to
;  TransferToPEI using the newly loaded GDT.
;  This code also enables the Cache-as-RAM
;
;  RETURNS:    none
;
;  MMX Usage:
;              MM0 = BIST State
;              MM1 = Current Package Physical Info
;                    [7:0]   = Cluster ID
;                    [15:8]  = Total Prossor pacakge detected in system
;                    [16] = BAD CMOS Flag
;                    [17] = AuburnDale or ClarksField
;                           [0] = AuburnDale
;                           [1] = ClarksField
;                    [18] = Contain SEC reset flag
;                           CPU Only Reset Flag
;                    [19] = Contain SEC reset flag
;                           Power Good Reset Flag
;                    [23:20] = Reserved
;                    [31:24] = Reserved
;              MM2 = store common MAX & MIN ratio
;              MM3 = Patch Revision
;              MM4 = Patch Pointer
;              MM5 = Save time-stamp counter value high32bit
;              MM6 = Save time-stamp counter value low32bit.
;              MM7 = Used in CALL_MMX & RET_ESI micaro
;
;------------------------------------------------------------------------------

; Nehalem Reset Boot Flow Start

align 4
_ModuleEntryPoint PROC NEAR C PUBLIC
  ;
  ; Save BIST state in MM0
  ;
  fninit                                ; clear any pending Floating point exceptions
  movd    mm0, eax

 ;
  ; Save time-stamp counter value
  ; rdtsc load 64bit time-stamp counter to EDX:EAX
  ;
  rdtsc
  movd    mm5, edx
  movd    mm6, eax
;----------------------------------------------------------------------------------------
; "Merlin" support
;----------------------------------------------------------------------------------------
  xor     eax, eax
  mov     es, ax
  mov     ax, cs
  mov     ds, ax

;******************************************************************************
; BEGIN WARM-START CHANGE
;******************************************************************************
;
; PLATFORM-SPECIFIC EQUATES!
; These equates define an address which has the following requirements
; on the target platform:
; 1. After booting DOS, the memory is not used by other DOS applications
;    or drivers (thus very platform/configuration specific). 
;    Minimum of roughly 8 bytes required.
; 2. The memory contents and address range are not affected by an INIT
; 3. By default, after booting DOS, the first 4 bytes at this address 
;    contain either 0 (cleared memory) or 0xFFFFFFFF.
; 4. After booting DOS, the memory is writable
;
; It's expected that a manual inspection (using ITP) is performed to ensure
; that the requirements are met. If the manual inspection fails, then a 
; different address must be identified, the below two equates must be
; changed accordingly, and the platform firmware must be rebuilt.
; Note that simply changing the platform hardware configuration could
; break this firmware because drivers may be loaded differently in
; memory, potentially using the address arbitrarily chosen here.
; 
  ;
  ; Check if value in magic address contains non-zero/non-FF value.
  ; It should actually contain executable code, typically a jmp 
  ; instruction.
  ;
  mov  ax, MAGIC_SEG
  mov es, ax
  mov al, BYTE PTR es:[MAGIC_ADDRESS_IN_SEG]

  ; Check for zero value
  cmp al, 0EAh ; EA is the FAR JMP opcode that Merlin inserts
  jz LegacyBiosWarmStart

  ; Check INIT# is asserted by port 0xCF9
  mov dx, 0CF9h
  in  al, dx
  cmp al, 04h
  jnz NotWarmStart

  ;
  ; Issue hard reset due to client silicon limitations, CPU Only Reset is not supported.
  ;
  mov dx, 0CF9h
  mov al, 06h
  out dx, al

LegacyBiosWarmStart:

  ;
  ; Check APIC_BASE_MSR.BIT8 to see if we're the BSP
  ;
  mov cx, MSR_APIC_BASE
  rdmsr
  test ah, 1
  jz TightLoop
  ;
  ; We're the BSP, so jump to the magic address. 
  ;
  DB  0EAh
  DW  MAGIC_ADDRESS_IN_SEG
  DW  MAGIC_SEG

  ; Not reached
NotWarmStart:

;******************************************************************************
; END WARM-START CHANGE
;******************************************************************************

  ;
  ; Enter Protected mode.
  ; 
  STATUS_CODE (01h)                     ; BSP_PROTECTED_MODE_START
  mov     esi,  OFFSET GdtDesc
  DB      66h
  lgdt    fword ptr cs:[si]
  mov     eax, cr0                      ; Get control register 0
  or      eax, 00000003h                ; Set PE bit (bit #0) & MP bit (bit #1)
  mov     cr0, eax                      ; Activate protected mode
  mov     eax, cr4                      ; Get control register 4
  or      eax, 00000600h                ; Set OSFXSR bit (bit #9) & OSXMMEXCPT bit (bit #10)
  mov     cr4, eax

  ;
  ; Now we're in Protected16
  ; Set up the selectors for protected mode entry
  ;
  mov     ax, SYS_DATA_SEL
  mov     ds, ax
  mov     es, ax
  mov     fs, ax
  mov     gs, ax
  mov     ss, ax

  ;
  ; Go to Protected32
  ;
  mov     esi, offset NemInitLinearAddress
  jmp     fword ptr cs:[si]

TightLoop:
  cli
  hlt
  jmp     TightLoop

_ModuleEntryPoint ENDP
_TEXT_REALMODE      ENDS

_TEXT_PROTECTED_MODE      SEGMENT PARA PUBLIC USE32 'CODE'
                          ASSUME  CS:_TEXT_PROTECTED_MODE, DS:_TEXT_PROTECTED_MODE

CALL_MMX macro   RoutineLabel

  local   ReturnAddress
  mov     esi, offset ReturnAddress
  movd    mm7, esi                      ; save ReturnAddress into MM7
  jmp     RoutineLabel
ReturnAddress:

endm

RET_ESI  macro

  movd    esi, mm7                      ; restore ESP from MM7
  jmp     esi

endm

CALL_EBP macro   RoutineLabel

  local   ReturnAddress
  mov     ebp, offset ReturnAddress
  jmp     RoutineLabel
ReturnAddress:

endm

RET_EBP  macro

  jmp     ebp                           ; restore ESP from EBP

endm

align 4
ProtectedModeSECStart PROC NEAR PUBLIC

  STATUS_CODE (02h)
  CALL_MMX  EnableAccessCSR             

  STATUS_CODE (03h)
  CALL_EBP  VeryEarlyMicrocodeUpdate

  STATUS_CODE (04h)
  CALL_MMX  DetectNumOfCPUSocket

  STATUS_CODE (05h)
  CALL_MMX  PlatformInitialization
  
  STATUS_CODE (06h)
  CALL_MMX  InitializeNEM

  STATUS_CODE (07h)
  CALL_MMX  EstablishStack

  STATUS_CODE (08h)
  jmp  CallPeiCoreEntryPoint

ProtectedModeSECStart ENDP

EnableAccessCSR    PROC    NEAR    PRIVATE
  ;
  ; get Bus number from CPUID[1] EBX[31:24]
  ;

  mov     eax, 0Bh
  mov     ecx, 1
  cpuid
  mov     esi, eax

  mov     eax, 1                        ; bus 0
  cpuid
  bswap   ebx
  movzx   eax, bl
  movzx   ebx, bl
  shl     eax, BSPApicIDSaveStart	; Save current BSP APIC ID in MM1[31:24]
  mov     cx, si
  shr     bl, cl			; get Bus number in BL 
  or      eax, ebx                     
  movd    mm1, eax                      ; save Bus number MM1[7:0]

  ;
  ; Enable MM PCI-E Config Space
  ; --cr-- use register symbol name; should upper 32 bit be cleared
  ;
  mov     eax, 080000060h               ; MCHBAR
  mov     dx, 0CF8h
  out     dx, eax
  mov     dx, 0CFCh
  mov     eax, 04h
  out     dx, eax
  in      eax, dx
  or      eax, MMCFG_BASE OR ENABLE
  out     dx, eax
  
  ; Clear reset flag
  movd    eax, mm1
  and     eax, NOT BIT18+BIT19
  movd    mm1, eax

  ;
  ; Enable SPI prefetching and caching
  ;
  mov     esi, PCH_LPC_BIOS_CNTL_PCI_ADDR       ; Bus0:Dev31:Func0:RegDCh
  and     BYTE PTR es:[esi], NOT (11b SHL 2)
  or      BYTE PTR es:[esi], (10b SHL 2)        ; D31:F0:RegDCh[3:2] = 10b

  RET_ESI

EnableAccessCSR    ENDP

;  STATUS_CODE (03h)
PlatformInitialization    PROC    NEAR    PRIVATE

  ;
  ; Program PCI Express base address
  ;

  mov   eax,  80000060h                           ; 0:0:0:60
  mov   dx,   0CF8h
  out   dx,   eax
  mov   dx,   0CFCh
  ;using Pcd instead
  ;mov   eax,  0e0000000h OR 00h OR 1
;  mov     eax, DWORD PTR PcdGet64 (PcdPciExpressBaseAddress)
  mov     eax, DWORD PTR PCIEXPRESS_BASE_ADDRESS
  or	eax, (PCIEX_LENGTH_BIT_SETTING OR 1)
  out   dx,   eax
  
  ;
  ; Enable Mch Bar
  ;
  mov     esi, MCHBAR_REG
  mov     eax, (MCH_BASE_ADDRESS + 1)
  mov     Dword Ptr [esi], eax

  ;
  ; Enable RCRB in PCH.
  ;
  mov     esi, PCH_LPC_RCRB_PCI_ADDR
  mov     eax, PCH_RCRB_BASE + 1
  mov     Dword Ptr [esi], eax
  
  ;
  ; Configure GPIO to be able to initiate LVL change for GPIO48 for S3 resume time calculation.
  ;
  ; Enable GPIO BASE I/O registers
  ;
  mov   eax,  PCI_LPC_BASE + 48h
  mov   dx,   0CF8h
  out   dx,   eax
  mov   eax,  GPIO_BASE_ADDRESS
  add   dx,   4
  out   dx,   eax

  mov   eax,  PCI_LPC_BASE + 4Ch
  mov   dx,   0CF8h
  out   dx,   eax
  add   dx,   4
  in    al,   dx
  or    al,   BIT4        ; GPIOBASE Enable
  out   dx,   al

  ;GPIO_USE_SEL2 Register -> 1 = GPIO 0 = Native
  mov   dx,   GPIO_BASE_ADDRESS + R_GPIO_USE_SEL2
  in    eax,  dx
  or    eax,  010000h     ;Enable GPIO48
  out   dx,   eax

  ;GP_IO_SEL2 Register -> 1 = Input 0 = Output (if Native Mode don't care)
  mov   dx,   GPIO_BASE_ADDRESS + R_GPIO_IO_SEL2
  in    eax,  dx
  and   eax,  0FFFEFFFFh  ;Configure GPIO48 as Output
  out   dx,   eax

  mov   dx,   GPIO_BASE_ADDRESS + R_GPIO_LVL2
  in    eax,  dx
  or    eax,  010000h     ;Configure GPIO48 as High
  out   dx,   eax

  ;
  ; Program and Enable ACPI PM Base.
  ;
  mov     esi, PCH_LPC_PMBASE_PCI_ADDR
  mov     eax, PCH_ACPI_BASE_ADDRESS + 1
  mov     Dword Ptr [esi], eax
  mov     esi, PCH_LPC_ACPICNTL_PCI_ADDR
  or      Dword Ptr [esi], 00000080h
  
  ;
  ; PCH BIOS Spec Rev 0.5.0 Section 12.9
  ; Additional Programming Requirements for USB Support
  ; Step 2.b
  ; Clear RCBA + 3598h [0] to 0b
  ;
  mov     esi, PCH_RCRB_BASE + 3598h
  mov     eax, 0
  mov     Dword Ptr [esi], eax

  ;
  ; Enable HPET decode in PCH.
  ;
  mov     esi, PCH_RCRB_BASE + PCH_RCRB_HPET
  mov     eax, PCH_RCRB_HPET_DECODE
  mov     Dword Ptr [esi], eax
  mov     eax, Dword ptr [esi]
  xor     eax, eax
  mov     esi, HPET_COMP_1
  mov     Dword Ptr [esi], eax
  mov     esi, HPET_COMP_2
  mov     Dword ptr [esi], eax

  ;
  ; Enable the upper 128-byte bank of RTC RAM.
  ;
  mov     esi, PCH_RCRB_BASE + PCH_RCRB_RTC_CONF
  mov     eax, Dword Ptr [esi]
  or      eax, PCH_RCRB_RTC_CONF_UCMOS_EN
  mov     Dword Ptr [esi], eax

  ;
  ; Choose Port80 Route
  ;
  mov     esi, PCH_RCRB_BASE + PCH_RCRB_GCS
  mov     ebx, Dword Ptr [esi]
  or      bl, BIT5

  ;
  ; check SETUP option - PchPort80Route
  ; 0 = LPC {Default]; 1 = PCI
  ;
;  mov     al, CMOS_PCH_PORT80_OFFSET    ; CMOS Offset = 17h
;  mov     dx, RTC_UPPER_INDEX
;  out     dx, al
;  inc     dx
;  in      al, dx
;  test    al, BIT0
;  jnz     @F
  and     bl, NOT (BIT2)                ; Port80h to LPC
;@@:
  mov     Dword Ptr [esi], ebx

  ;
  ; Halt TCO Timer
  ;
  mov     dx, 0468h
  in      ax, dx
  or      ax, BIT11
  out     dx, ax

  ;
  ; Clear the Second TO status bit
  ;
  mov     dx, 0466h
  in      ax, dx
  or      ax, BIT1
  out     dx, ax

  RET_ESI

PlatformInitialization    ENDP

;  STATUS_CODE (03h)
DetectNumOfCPUSocket    PROC    NEAR    PRIVATE

  ; only one socket
  movd  eax, mm1                        ; get MM1 value into EAX
  mov  ah, 01
  movd   mm1, eax                       ; save CPU pkg count into MM1[15:8]

  RET_ESI

DetectNumOfCPUSocket    ENDP

;  STATUS_CODE (07h)
VeryEarlyMicrocodeUpdate    PROC    NEAR    PRIVATE

IF EARLY_MICROCODE_SUPPORT
    mov     ecx, IA32_BIOS_SIGN_ID
    rdmsr                               ; CPU PatchID -> EDX
    cmp     edx, 0                      ; If microcode has been updated
    jnz     luExit                      ; Skip if patch already loaded

    mov     ecx, IA32_PLATFORM_ID       ; To get Platform ID.
    rdmsr
    shr     edx, 18                     ; EDX[0-2] = Platform ID.
    and     dx, 07h                     ; DX = Platform ID.
    mov     si, dx                      ; Save Platform ID in FS.
    mov     eax, 01h                    ; To get CPU signature.
    cpuid                               ; EAX = CPU signature.
    mov     cx, si                      ; CX = Platform ID
    xor     edx, edx
    bts     dx, cx                      ; EDX = Platform ID bit.

;    mov     esi, PcdGet32 (PcdFlashMicrocodeFvBase)
    mov     esi, MICROCODE_FV_BASE_ADDRESS
    
    mov     ebx, esi
    mov     bx,  FVHEADER_LEN_OFF
    movzx   ebx, WORD PTR [ebx]
    add     esi, ebx
    add     si,  FFSHEADER_LEN ; add FFS header

;    mov     edi, PcdGet32 (PcdFlashMicrocodeFvBase)
;    mov     ebx, PcdGet32 (PcdFlashMicrocodeFvSize)
    mov     edi, MICROCODE_FV_BASE_ADDRESS
    mov     ebx, MICROCODE_FV_SIZE
    add     edi, ebx                          ;End addr of uCodes.
    
    ; EAX = CPU signature.
    ; EDX = Platform ID bit.
    ; ESI = Abs addr of contiguous uCode blocks.
    ; EDI = Abs addr of contiguous uCode blocks end.

luCheckPatch:
    cmp     (UpdateHeaderStruc PTR ds:[esi]).dProcessorSignature, eax;Sig matched?
    jnz     luCheckUnprogrammed         ; No.
    test    (UpdateHeaderStruc PTR ds:[esi]).dProcessorFlags, edx;Platform matched?
    jnz luFoundMatch                    ; Yes.

luCheckUnprogrammed:
    mov     ebx, (UpdateHeaderStruc PTR ds:[esi]).dDataSize
    cmp     ebx, 0FFFFFFFFh
    je      luUnprogrammed
    cmp     (UpdateHeaderStruc PTR ds:[esi]).dLoaderRevision, 1
    je      luCheckExtdHdrs 

luUnprogrammed:
    mov     ebx, 1024                   ; Unprogrammed space, 1KB checks
    jmp     luPoinToNextBlock           ; for backword compatibility.

luCheckExtdHdrs:
    add     ebx, SIZEOF(UpdateHeaderStruc)
    cmp     ebx, (UpdateHeaderStruc PTR ds:[esi]).dTotalSize
    jae     luTryNextPatch              ; No extd hdrs.

    mov ecx, DWORD PTR ds:[esi + ebx]
    jcxz    luTryNextPatch              ; No extd hdrs. (OK to use CX instead of ECX).
    add ebx, 20                         ; Point to the first Extd Sig.
luNextSig:
    cmp     eax, DWORD PTR ds:[esi + ebx] ;Sig matched?
    jne     lu_00
    test    edx, DWORD PTR ds:[esi + ebx + 4] ;Platform matched?
    jnz     luFoundMatch
lu_00:
    add ebx, 12
    loop    luNextSig

luTryNextPatch:
    mov     ebx, (UpdateHeaderStruc PTR ds:[esi]).dTotalSize
    or      ebx, ebx
    jnz     luPoinToNextBlock           ; Variable size uCode format.
    mov     ebx, BLOCK_LENGTH_BYTES     ; Fixed size uCode format. 

;
; Add alignment check - begin
;
    test ebx, 0400h
    jz   @F
    add  ebx, 0400h
@@:
;
; Add alignment check - end
;

luPoinToNextBlock:
    add     esi, ebx
    cmp     esi, edi
    jb      luCheckPatch                ; Check with all patches.

    ; Check possible multiple patch
    movd eax, mm3
    movd esi, mm4
    or   eax, eax
    jnz  luLoadPatch
    jmp     luExit                      ; No matching patch found.

luFoundMatch:
;              MM3 = Patch Revision
;              MM4 = Patch Pointer
    movd ebx, mm3
    cmp  (UpdateHeaderStruc PTR ds:[esi]).dUpdateRevision, ebx
    jb   luTryNextPatch

    mov  ebx, (UpdateHeaderStruc PTR ds:[esi]).dUpdateRevision

luStoreRevPtr:
    movd mm3, ebx                        ; save Patch Revision
    movd mm4, esi                        ; save Patch Pointer
    jmp luTryNextPatch

luLoadPatch:
    mov ecx, IA32_BIOS_UPDT_TRIG
    mov     eax, esi                    ; EAX - Abs addr of uCode patch.
    add     eax, SIZEOF(UpdateHeaderStruc)  ; EAX - Abs addr of uCode data.
    xor     edx, edx                    ; EDX:EAX - Abs addr of uCode data.
    wrmsr                               ; Trigger uCode load.

luExit:

ENDIF

    RET_EBP
VeryEarlyMicrocodeUpdate    ENDP


;  STATUS_CODE (09h)
;************************************************************
; Description:
;
;   This function initializes the Cache for Data, Stack, and Code
;   as specified in the  BIOS Writer's Guide.
;************************************************************
InitializeNEM    PROC    NEAR    PRIVATE
IFDEF BOOT_GUARD_SUPPORT_FLAG
  ;
  ; Detect Boot Guard Boot
  ;
  mov     ecx, MSR_BOOT_GUARD_SACM_INFO    ; 
  rdmsr   
  and     eax, 01h
  jnz     BootGuardNemSetup
ENDIF

  ;
  ;  Enable cache for use as stack and for caching code
  ;  The algorithm is specified in the processor BIOS writer's guide
  ;

  ;
  ;  Ensure that the system is in flat 32 bit protected mode. 
  ;
  ;  Platform Specific - configured earlier
  ;
  ;  Ensure that only one logical processor in the system is the BSP.
  ;  (Required step for clustered systems).
  ;
  ;  Platform Specific - configured earlier
  
  ;  Ensure all APs are in the Wait for SIPI state.
  ;  This includes all other logical processors in the same physical processor
  ;  as the BSP and all logical processors in other physical processors.
  ;  If any APs are awake, the BIOS must put them back into the Wait for
  ;  SIPI state by issuing a broadcast INIT IPI to all excluding self.
  ;
  mov     edi, APIC_ICR_LO               ; 0FEE00300h - Send INIT IPI to all excluding self 
  mov     eax, ORAllButSelf + ORSelfINIT ; 0000C4500h
  mov     [edi], eax

@@:
  mov     eax, [edi]
  bt      eax, 12                       ; Check if send is in progress
  jc      @B                            ; Loop until idle

  ;
  ;   Load microcode update into BSP.
  ;
  ;   Ensure that all variable-range MTRR valid flags are clear and 
  ;   IA32_MTRR_DEF_TYPE MSR E flag is clear.  Note: This is the default state
  ;   after hardware reset.
  ;
  ;   Platform Specific - MTRR are usually in default state.
  ;

  ;
  ;   Initialize all fixed-range and variable-range MTRR register fields to 0.
  ;
   mov   ecx, IA32_MTRR_CAP         ; get variable MTRR support
   rdmsr
   movzx ebx, al                    ; EBX = number of variable MTRR pairs
   shl   ebx, 2                     ; *4 for Base/Mask pair and WORD size
   add   ebx, MtrrCountFixed * 2    ; EBX = size of  Fixed and Variable MTRRs

   xor   eax, eax                       ; Clear the low dword to write
   xor   edx, edx                       ; Clear the high dword to write
   ;;;mov   ebx, MtrrCount * 2             ; ebx <- sizeof MtrrInitTable
InitMtrrLoop:
   add   ebx, -2
   movzx ecx, WORD PTR cs:MtrrInitTable[ebx]  ; ecx <- address of mtrr to zero
   wrmsr
   jnz   InitMtrrLoop                   ; loop through the whole table
  
  ;
  ;   Configure the default memory type to un-cacheable (UC) in the 
  ;   IA32_MTRR_DEF_TYPE MSR.
  ;
  mov     ecx, MTRR_DEF_TYPE            ; Load the MTRR default type index
  rdmsr
  and     eax, NOT (00000CFFh)          ; Clear the enable bits and def type UC.
  wrmsr
  
  ; Configure MTRR_PHYS_MASK_HIGH for proper addressing above 4GB
  ; based on the physical address size supported for this processor
  ; This is based on read from CPUID EAX = 080000008h, EAX bits [7:0]
  ; 
  ; Examples: 
  ;  MTRR_PHYS_MASK_HIGH = 00000000Fh  For 36 bit addressing
  ;  MTRR_PHYS_MASK_HIGH = 0000000FFh  For 40 bit addressing
  ;
  mov   eax, 80000008h                  ; Address sizes leaf
  cpuid  
  sub   al, 32
  movzx eax, al
  xor   esi, esi
  bts   esi, eax
  dec   esi                             ; esi <- MTRR_PHYS_MASK_HIGH

  ;   
  ;   Configure the DataStack region as write-back (WB) cacheable memory type
  ;   using the variable range MTRRs.
  ;

  ;
  ; Set the base address of the DataStack cache range
  ;
;  mov     eax, PcdGet32 (PcdTemporaryRamBase)
  mov     eax, TEMPORARY_RAM_BASE_ADDRESS
  or      eax, MTRR_MEMORY_TYPE_WB
                                        ; Load the write-back cache value
  xor     edx, edx                      ; clear upper dword
  mov     ecx, MTRR_PHYS_BASE_0         ; Load the MTRR index
  wrmsr                                 ; the value in MTRR_PHYS_BASE_0
  
  ;
  ; Set the mask for the DataStack cache range
  ; Compute MTRR mask value:  Mask = NOT (Size - 1)
  ;
;  mov  eax, PcdGet32 (PcdTemporaryRamSize)
  mov  eax, TEMPORARY_RAM_SIZE
  dec  eax
  not  eax
  or   eax, MTRR_PHYS_MASK_VALID
                                        ; turn on the Valid flag
  mov  edx, esi                         ; edx <- MTRR_PHYS_MASK_HIGH
  mov  ecx, MTRR_PHYS_MASK_0            ; For proper addressing above 4GB
  wrmsr                                 ; the value in MTRR_PHYS_BASE_0

  ;
  ;   Configure the BIOS code region as write-protected (WP) cacheable 
  ;   memory type using a single variable range MTRR.
  ;
  ;   Platform Specific - ensure region to cache meets MTRR requirements for 
  ;   size and alignment.
  ;

  ;
  ; Save MM5 into ESP before program MTRR, because program MTRR will use MM5 as the local variable.
  ; And, ESP is not initialized before CAR is enabled. So, it is safe ot use ESP here.
  ;
  movd esp, mm5
  
  ;
  ; Get total size of cache from PCD if it need fix value
  ;
;  mov     eax, PcdGet32 (PcdNemCodeCacheSize)
  mov     eax, CODE_CACHE_SIZE
  ;
  ; Calculate NEM size
  ; Determine LLC size by following RS - Haswell Processor Family BIOS Writer's Guide (BWG) 0.3.0
  ; Section 4.4.5 - The size of the code region and data region combined must not exceed the size 
  ; of the (Last Level Cache - 0.5MB).
  ;
  ; Determine Cache Parameter by CPUID Function 04h
  ;
  xor     ecx, ecx
  xor     edi, edi

Find_LLC_parameter:
  mov     ecx, edi
  mov     eax, 4
  cpuid
  inc     edi
  and     eax, 01Fh                      ; If EAX[4:0]=0, which indicates no more caches, then we can get LLC parameters
  jnz     Find_LLC_parameter
  ;
  ; LLC configuration is pointed to edi-2
  ;
  dec     edi
  dec     edi
  mov     ecx, edi
  mov     eax, 4
  cpuid
  ;
  ; Got LLC parameters
  ;
  ; This Cache Size in Bytes = (Ways + 1) * (Partitions + 1) * (Line_Size + 1) * (Sets + 1)
  ;  = (EBX[31:22] + 1) * (EBX[21:12] + 1) * (EBX[11:0] + 1) * (ECX + 1)
  ;
  mov     eax, ecx
  inc     eax
  mov     edi, ebx
  shr     ebx, 22
  inc     ebx
  mul     ebx
  mov     ebx, edi
  and     ebx, NOT 0FFC00FFFh
  shr     ebx, 12
  inc     ebx
  mul     ebx
  mov     ebx, edi
  and     ebx, 0FFFh
  inc     ebx
  mul     ebx
  ;
  ; Maximum NEM size <= (Last Level Cache - 0.5MB) 
  ; 
  sub     eax, 512*1024
Got_NEM_size:
  ;
  ; Code cache size = Total NEM size - DataStack size
  ;
;  sub     eax, PcdGet32 (PcdTemporaryRamSize)
  sub     eax, TEMPORARY_RAM_SIZE
  ;
  ; Set the base address of the CodeRegion cache range from PCD
  ; PcdNemCodeCacheBase is set to the offset to flash base, 
  ; so add PcdFlashAreaBaseAddress to get the real code base address.
  ;
;  mov     edi, PcdGet32 (PcdNemCodeCacheBase)
;  add     edi, PcdGet32 (PcdFlashAreaBaseAddress)
  mov     edi, CODE_CACHE_BASE_ADDRESS
  add     edi, FLASH_AREA_BASE_ADDRESS

  ;
  ; Round up to page size
  ;
  mov     ecx, eax                      ; Save
  and     ecx, 0FFFF0000h               ; Number of pages in 64K
  and     eax, 0FFFFh                   ; Number of "less-than-page" bytes
  jz      Rounded
  mov     eax, 10000h                   ; Add the whole page size

Rounded:
  add     eax, ecx                      ; eax - rounded up code cache size

  ;
  ; Define "local" vars for this routine
  ; Note that mm0 is used to store BIST result for BSP,
  ; mm1 is used to store the number of processor and BSP APIC ID,
  ; mm6 is used to save time-stamp counter value.
  ;
  CODE_SIZE_TO_CACHE    TEXTEQU  <mm3>
  CODE_BASE_TO_CACHE    TEXTEQU  <mm4>
  NEXT_MTRR_INDEX       TEXTEQU  <mm5>
  NEXT_MTRR_SIZE        TEXTEQU  <mm2>
  ;
  ; Initialize "locals"
  ;
  sub     ecx, ecx
  movd    NEXT_MTRR_INDEX, ecx          ; Count from 0 but start from MTRR_PHYS_BASE_1

  ;
  ; Save remaining size to cache
  ;
  movd    CODE_SIZE_TO_CACHE, eax       ; Size of code cache region that must be cached
  movd    CODE_BASE_TO_CACHE, edi       ; Base code cache address

NextMtrr:
  ;
  ; Get remaining size to cache
  ;
  movd    eax, CODE_SIZE_TO_CACHE
  and     eax, eax
  jz      CodeRegionMtrrdone            ; If no left size - we are done
  ;
  ; Determine next size to cache.
  ; We start from bottom up. Use the following algorythm:
  ; 1. Get our own alignment. Max size we can cache equals to our alignment
  ; 2. Determine what is bigger - alignment or remaining size to cache.
  ;    If aligment is bigger - cache it.
  ;      Adjust remaing size to cache and base address
  ;      Loop to 1.
  ;    If remaining size to cache is bigger
  ;      Determine the biggest 2^N part of it and cache it.
  ;      Adjust remaing size to cache and base address
  ;      Loop to 1.
  ; 3. End when there is no left size to cache or no left MTRRs
  ;
  movd    edi, CODE_BASE_TO_CACHE
  bsf     ecx, edi                      ; Get index of lowest bit set in base address
  ;
  ; Convert index into size to be cached by next MTRR
  ;
  mov     edx, 1h
  shl     edx, cl                       ; Alignment is in edx
  cmp     edx, eax                      ; What is bigger, alignment or remaining size?
  jbe     gotSize                       ; JIf aligment is less
  ;
  ; Remaining size is bigger. Get the biggest part of it, 2^N in size
  ;
  bsr     ecx, eax                      ; Get index of highest set bit
  ;
  ; Convert index into size to be cached by next MTRR
  ;
  mov     edx, 1
  shl     edx, cl                       ; Size to cache

GotSize:
  mov     eax, edx
  movd    NEXT_MTRR_SIZE, eax           ; Save

  ;
  ; Compute MTRR mask value:  Mask = NOT (Size - 1)
  ;
  dec     eax                           ; eax - size to cache less one byte
  not     eax                           ; eax contains low 32 bits of mask
  or      eax, MTRR_PHYS_MASK_VALID     ; Set valid bit

  ;
  ; Program mask register
  ;
  mov     ecx, MTRR_PHYS_MASK_1         ; setup variable mtrr
  movd    ebx, NEXT_MTRR_INDEX
  add     ecx, ebx

  mov     edx, esi                      ; edx <- MTRR_PHYS_MASK_HIGH
  wrmsr
  ;
  ; Program base register
  ;
  sub     edx, edx
  mov     ecx, MTRR_PHYS_BASE_1         ; setup variable mtrr
  add     ecx, ebx                      ; ebx is still NEXT_MTRR_INDEX

  movd    eax, CODE_BASE_TO_CACHE
  or      eax, MTRR_MEMORY_TYPE_WP      ; set type to write protect
  wrmsr
  ;
  ; Advance and loop
  ; Reduce remaining size to cache
  ;
  movd    ebx, CODE_SIZE_TO_CACHE
  movd    eax, NEXT_MTRR_SIZE
  sub     ebx, eax
  movd    CODE_SIZE_TO_CACHE, ebx

  ;
  ; Increment MTRR index
  ;
  movd    ebx, NEXT_MTRR_INDEX
  add     ebx, 2
  movd    NEXT_MTRR_INDEX, ebx
  ;
  ; Increment base address to cache
  ;
  movd    ebx, CODE_BASE_TO_CACHE 
  movd    eax, NEXT_MTRR_SIZE
  add     ebx, eax
  ;
  ; if carry happens, means NEM base + size over 4G
  ;
  jc      CodeRegionMtrrdone
  movd    CODE_BASE_TO_CACHE, ebx 

  jmp     NextMtrr

CodeRegionMtrrdone:
  ; Program the variable MTRR's MASK register for WDB
  ; (Write Data Buffer, used in MRC, must be WC type)
  ;
  mov     ecx, MTRR_PHYS_MASK_1
  movd    ebx, NEXT_MTRR_INDEX
  add     ecx, ebx
  mov     edx, esi                                          ; edx <- MTRR_PHYS_MASK_HIGH
  mov     eax, WDB_REGION_SIZE_MASK OR MTRR_PHYS_MASK_VALID ; turn on the Valid flag
  wrmsr

  ;
  ; Program the variable MTRR's BASE register for WDB
  ;
  dec     ecx
  xor     edx, edx
  mov     eax, WDB_REGION_BASE_ADDRESS OR MTRR_MEMORY_TYPE_WC
  wrmsr

  ;
  ; Enable the MTRRs by setting the IA32_MTRR_DEF_TYPE MSR E flag.
  ;
  mov     ecx, MTRR_DEF_TYPE            ; Load the MTRR default type index
  rdmsr
  or      eax, MTRR_DEF_TYPE_E          ; Enable variable range MTRRs
  wrmsr

  ;
  ;   Enable the logical processor's (BSP) cache: execute INVD and set 
  ;   CR0.CD = 0, CR0.NW = 0.
  ;
  mov     eax, cr0
  and     eax, NOT (CR0_CACHE_DISABLE + CR0_NO_WRITE)
  invd
  mov     cr0, eax
  ;
  ;   Enable No-Eviction Mode Setup State by setting
  ;   NO_EVICT_MODE  MSR 2E0h bit [0] = '1'.
  ;
  mov     ecx, NO_EVICT_MODE 
  rdmsr
  or      eax, 1
  wrmsr

  ;
  ; Restore MM5 from ESP after program MTRR
  ;
  movd mm5, esp

  ;
  ;   One location in each 64-byte cache line of the DataStack region
  ;   must be written to set all cache values to the modified state.
  ;
;  mov     edi, PcdGet32 (PcdTemporaryRamBase)
;  mov     ecx, PcdGet32 (PcdTemporaryRamSize)
  mov     edi, TEMPORARY_RAM_BASE_ADDRESS
  mov     ecx, TEMPORARY_RAM_SIZE
  shr     ecx, 6
  mov     eax, CACHE_INIT_VALUE
@@:
  mov  [edi], eax
  sfence
  add  edi, 64
  loopd  @b

  ;
  ;   Enable No-Eviction Mode Run State by setting
  ;   NO_EVICT_MODE MSR 2E0h bit [1] = '1'.
  ;
  mov     ecx, NO_EVICT_MODE
  rdmsr
  or      eax, 2
  wrmsr
  
IFDEF BOOT_GUARD_SUPPORT_FLAG
  jmp     FinishedCacheConfig
  
  ;
  ; Jump to here when Boot Guard boot and NEM is initialized by Boot Guard ACM
  ;
BootGuardNemSetup:
  ;
  ; Finished with cache configuration
  ;
  ; Configure MTRR_PHYS_MASK_HIGH for proper addressing above 4GB
  ; based on the physical address size supported for this processor
  ; This is based on read from CPUID EAX = 080000008h, EAX bits [7:0]
  ; 
  ; Examples: 
  ;  MTRR_PHYS_MASK_HIGH = 00000000Fh  For 36 bit addressing
  ;  MTRR_PHYS_MASK_HIGH = 0000000FFh  For 40 bit addressing
  ;
  mov   eax, 80000008h                  ; Address sizes leaf
  cpuid  
  sub   al, 32
  movzx eax, al
  xor   esi, esi
  bts   esi, eax
  dec   esi                             ; esi <- MTRR_PHYS_MASK_HIGH

  ;   
  ;   Configure the DataStack region as write-back (WB) cacheable memory type
  ;   using the variable range MTRRs.
  ;
  ;
  ; Find available MTRR
  ;
  CALL_EBP     FindFreeMtrr
  
  ;
  ; Set the base address of the DataStack cache range
  ;
;  mov     eax, PcdGet32 (PcdTemporaryRamBase)
  mov     eax, TEMPORARY_RAM_BASE_ADDRESS
  or      eax, MTRR_MEMORY_TYPE_WB
                                        ; Load the write-back cache value
  xor     edx, edx                      ; clear upper dword
  wrmsr                                 ; the value in MTRR_PHYS_BASE_0
  
  ;
  ; Set the mask for the DataStack cache range
  ; Compute MTRR mask value:  Mask = NOT (Size - 1)
  ;
;  mov  eax, PcdGet32 (PcdTemporaryRamSize)
  mov  eax, TEMPORARY_RAM_SIZE
  dec  eax
  not  eax
  or   eax, MTRR_PHYS_MASK_VALID
                                        ; turn on the Valid flag
  mov  edx, esi                         ; edx <- MTRR_PHYS_MASK_HIGH
  inc  ecx
  wrmsr                                 ; the value in MTRR_PHYS_BASE_0

  ;
  ; Program the variable MTRR's MASK register for WDB
  ; (Write Data Buffer, used in MRC, must be WC type)
  ;
  
  ;
  ; Find available MTRR
  ;
  CALL_EBP     FindFreeMtrr

FoundAvailableMtrr:
  ;
  ; Program the variable MTRR's BASE register for WDB
  ;
  xor     edx, edx
  mov     eax, WDB_REGION_BASE_ADDRESS OR MTRR_MEMORY_TYPE_WC
  wrmsr

  inc     ecx
  mov     edx, esi                                          ; edx <- MTRR_PHYS_MASK_HIGH
  mov     eax, WDB_REGION_SIZE_MASK OR MTRR_PHYS_MASK_VALID ; turn on the Valid flag
  wrmsr

  ;
  ;   One location in each 64-byte cache line of the DataStack region
  ;   must be written to set all cache values to the modified state.
  ;
;  mov     edi, PcdGet32 (PcdTemporaryRamBase)
;  mov     ecx, PcdGet32 (PcdTemporaryRamSize)
  mov     edi, TEMPORARY_RAM_BASE_ADDRESS
  mov     ecx, TEMPORARY_RAM_SIZE
  shr     ecx, 6
  mov     eax, CACHE_INIT_VALUE
@@:
  mov  [edi], eax
  sfence
  add  edi, 64
  loopd  @b
ENDIF

  ;
  ; Finished with cache configuration
  ;
FinishedCacheConfig:

  ;
  ; Optionally Test the Region...
  ;  
  
  ;
  ; Test area by writing and reading
  ;
  cld
;  mov     edi, PcdGet32 (PcdTemporaryRamBase)
;  mov     ecx, PcdGet32 (PcdTemporaryRamSize) 
  mov     edi, TEMPORARY_RAM_BASE_ADDRESS
  mov     ecx, TEMPORARY_RAM_SIZE 
  shr     ecx, 2
  mov     eax, CACHE_TEST_VALUE
TestDataStackArea:
  stosd
  cmp     eax, DWORD PTR [edi-4]
  jnz     DataStackTestFail
  loop    TestDataStackArea 
  jmp     DataStackTestPass

  ;
  ; Cache test failed
  ;
DataStackTestFail:
  STATUS_CODE (0D0h)
  jmp     $

  ;
  ; Configuration test failed
  ;
ConfigurationTestFailed:
  STATUS_CODE (0D1h)
  jmp     $

DataStackTestPass:

  ;
  ; At this point you may continue normal execution.  Typically this would include 
  ; reserving stack, initializing the stack pointer, etc.
  ;

  ;
  ; After memory initialization is complete, please follow the algorithm in the BIOS
  ; Writer's Guide to properly transition to a normal system configuration.
  ; The algorithm covers the required sequence to properly exit this mode.
  ;

  RET_ESI

InitializeNEM    ENDP

;  STATUS_CODE (09h)
EstablishStack    PROC    NEAR    PRIVATE

  ;
  ; Enable STACK
  ;
  RET_ESI

EstablishStack    ENDP

FindFreeMtrr    PROC    NEAR    PRIVATE
  mov    ecx, MTRR_PHYS_MASK_0

@@:
  rdmsr
  test   eax, 800h
  jz     FoundFreeMtrr
  add    ecx, 2
  cmp    ecx, MTRR_PHYS_MASK_9
  jbe    @b
  ;
  ; No available MTRR, halt system
  ;
  jmp    $
  
FoundFreeMtrr:
  dec    ecx
  
  RET_EBP

FindFreeMtrr    ENDP

;  STATUS_CODE (0Bh)
CallPeiCoreEntryPoint   PROC    NEAR    PRIVATE
  ;
  ; Set stack top pointer
  ;
;  mov     esp, PcdGet32 (PcdTemporaryRamBase)
;  add     esp, PcdGet32 (PcdTemporaryRamSize)
  mov     esp, TEMPORARY_RAM_BASE_ADDRESS
  add     esp, TEMPORARY_RAM_SIZE

  ;
  ; Push CPU count to stack first, then AP's (if there is one)
  ; BIST status, and then BSP's
  ;

  ;
  ; Here work around for BIST
  ;
  ; Get number of BSPs
  movd    ecx, mm1
  movzx   ecx, ch

  ; Save number of BSPs
  push  ecx

GetSBSPBist:
  ; Save SBSP BIST 
  movd  eax, mm0 
  push  eax

  ; Save SBSP APIC ID
  movd  eax, mm1 
  shr   eax, BSPApicIDSaveStart               ; Resume APIC ID 
  push  eax

  ; Save Time-Stamp Counter
  movd eax, mm5
  push eax

  movd eax, mm6
  push eax

TransferToSecStartup:



  ; Switch to "C" code
  STATUS_CODE (0Ch)
  ;
  ; Pass entry point of the PEI core
  ;
  mov     edi, PEI_CORE_ENTRY_BASE      ; 0FFFFFFE0h
  push    DWORD PTR ds:[edi]

  ;
  ; Pass BFV into the PEI Core
  ;
  mov     edi, FV_MAIN_BASE             ; 0FFFFFFFCh
  push    DWORD PTR ds:[edi]

  ; ECPoverride: SecStartup entry point needs 4 parameters
;  push    PcdGet32 (PcdTemporaryRamBase)
  push    TEMPORARY_RAM_BASE_ADDRESS

  ;
  ; Pass stack size into the PEI Core
  ;
;  push    PcdGet32 (PcdTemporaryRamSize)
  push    TEMPORARY_RAM_SIZE

  ;
  ; Pass Control into the PEI Core
  ;
  call SecStartup
CallPeiCoreEntryPoint   ENDP

StartUpAp       PROC    NEAR

  mov     esi, HPET_COMP_2
  lock    inc  byte ptr [esi]

  DISABLE_CACHE
;
; Halt the AP and wait for the next SIPI
;
Ap_Halt:
  cli
@@:
  hlt
  jmp     @B
  ret
StartUpAp       ENDP


CheckValidCMOS    PROC    NEAR    PRIVATE
  ;
  ; Check CMOS Status
  ;
  mov     esi, PCH_LPC_GEN_PMCON_3_ADDR
  mov     eax, es:[esi]
  
  ; check PWR_FLR and RTC_PWR_STS status 
  and     eax, BIT2 + BIT1
   
  RET_EBP
CheckValidCMOS    ENDP

MtrrInitTable   LABEL BYTE
    DW  MTRR_DEF_TYPE
    DW  MTRR_FIX_64K_00000
    DW  MTRR_FIX_16K_80000
    DW  MTRR_FIX_16K_A0000
    DW  MTRR_FIX_4K_C0000
    DW  MTRR_FIX_4K_C8000
    DW  MTRR_FIX_4K_D0000
    DW  MTRR_FIX_4K_D8000
    DW  MTRR_FIX_4K_E0000
    DW  MTRR_FIX_4K_E8000
    DW  MTRR_FIX_4K_F0000
    DW  MTRR_FIX_4K_F8000

MtrrCountFixed EQU (($ - MtrrInitTable) / 2)

    DW  MTRR_PHYS_BASE_0
    DW  MTRR_PHYS_MASK_0
    DW  MTRR_PHYS_BASE_1
    DW  MTRR_PHYS_MASK_1
    DW  MTRR_PHYS_BASE_2
    DW  MTRR_PHYS_MASK_2
    DW  MTRR_PHYS_BASE_3
    DW  MTRR_PHYS_MASK_3
    DW  MTRR_PHYS_BASE_4
    DW  MTRR_PHYS_MASK_4
    DW  MTRR_PHYS_BASE_5
    DW  MTRR_PHYS_MASK_5
    DW  MTRR_PHYS_BASE_6
    DW  MTRR_PHYS_MASK_6
    DW  MTRR_PHYS_BASE_7
    DW  MTRR_PHYS_MASK_7
    DW  MTRR_PHYS_BASE_8
    DW  MTRR_PHYS_MASK_8
    DW  MTRR_PHYS_BASE_9
    DW  MTRR_PHYS_MASK_9
MtrrCount      EQU (($ - MtrrInitTable) / 2)

align 10h
PUBLIC  BootGDTtable

;
; GDT[0]: 0x00: Null entry, never used.
;
NULL_SEL        EQU $ - GDT_BASE        ; Selector [0]
GDT_BASE:
BootGDTtable        DD  0
                    DD  0
;
; Linear data segment descriptor
;
LINEAR_SEL      EQU $ - GDT_BASE        ; Selector [0x8]
    DW  0FFFFh                          ; limit 0xFFFFF
    DW  0                               ; base 0
    DB  0
    DB  092h                            ; present, ring 0, data, expand-up, writable
    DB  0CFh                            ; page-granular, 32-bit
    DB  0
;
; Linear code segment descriptor
;
LINEAR_CODE_SEL EQU $ - GDT_BASE        ; Selector [0x10]
    DW  0FFFFh                          ; limit 0xFFFFF
    DW  0                               ; base 0
    DB  0
    DB  09Bh                            ; present, ring 0, data, expand-up, not-writable
    DB  0CFh                            ; page-granular, 32-bit
    DB  0
;
; System data segment descriptor
;
SYS_DATA_SEL    EQU $ - GDT_BASE        ; Selector [0x18]
    DW  0FFFFh                          ; limit 0xFFFFF
    DW  0                               ; base 0
    DB  0
    DB  093h                            ; present, ring 0, data, expand-up, not-writable
    DB  0CFh                            ; page-granular, 32-bit
    DB  0

;
; System code segment descriptor
;
SYS_CODE_SEL    EQU $ - GDT_BASE        ; Selector [0x20]
    DW  0FFFFh                          ; limit 0xFFFFF
    DW  0                               ; base 0
    DB  0
    DB  09Ah                            ; present, ring 0, data, expand-up, writable
    DB  0CFh                            ; page-granular, 32-bit
    DB  0
;
; Spare segment descriptor
;
SYS16_CODE_SEL  EQU $ - GDT_BASE        ; Selector [0x28]
    DW  0FFFFh                          ; limit 0xFFFFF
    DW  0                               ; base 0
    DB  0Eh                             ; Changed from F000 to E000.
    DB  09Bh                            ; present, ring 0, code, expand-up, writable
    DB  00h                             ; byte-granular, 16-bit
    DB  0
;
; Spare segment descriptor
;
SYS16_DATA_SEL  EQU $ - GDT_BASE        ; Selector [0x30]
    DW  0FFFFh                          ; limit 0xFFFF
    DW  0                               ; base 0
    DB  0
    DB  093h                            ; present, ring 0, data, expand-up, not-writable
    DB  00h                             ; byte-granular, 16-bit
    DB  0

;
; Spare segment descriptor
;
SPARE5_SEL      EQU $ - GDT_BASE        ; Selector [0x38]
    DW  0                               ; limit 0
    DW  0                               ; base 0
    DB  0
    DB  0                               ; present, ring 0, data, expand-up, writable
    DB  0                               ; page-granular, 32-bit
    DB  0
GDT_SIZE        EQU $ - BootGDTtable    ; Size, in bytes

GdtDesc:                                ; GDT descriptor
OffsetGDTDesc   EQU $ - _ModuleEntryPoint
    DW  GDT_SIZE - 1                    ; GDT limit
    DD  OFFSET BootGDTtable             ; GDT base address

NemInitLinearAddress   LABEL   FWORD
NemInitLinearOffset    LABEL   DWORD
    DD  OFFSET ProtectedModeSECStart    ; Offset of our 32 bit code
    DW  LINEAR_CODE_SEL

TopOfCar  DD  TEMPORARY_RAM_BASE_ADDRESS + TEMPORARY_RAM_SIZE

_TEXT_PROTECTED_MODE    ENDS
END
