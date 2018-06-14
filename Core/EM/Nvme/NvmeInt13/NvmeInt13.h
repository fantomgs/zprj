//**********************************************************************
//**********************************************************************
//**                                                                  **
//**        (C)Copyright 1985-2014, American Megatrends, Inc.         **
//**                                                                  **
//**                       All Rights Reserved.                       **
//**                                                                  **
//**         5555 Oakbrook Parkway, Suite 200, Norcross, GA 30093     **
//**                                                                  **
//**                       Phone: (770)-246-8600                      **
//**                                                                  **
//**********************************************************************
//**********************************************************************
//**********************************************************************
// $Header: /Alaska/SOURCE/Modules/NVMe/NvmeInt13/NvmeInt13.h 1     9/04/14 7:56a Anandakrishnanl $
//
// $Revision: 1 $
//
// $Date: 9/04/14 7:56a $
//**********************************************************************
// Revision History
// ----------------
// $Log: /Alaska/SOURCE/Modules/NVMe/NvmeInt13/NvmeInt13.h $
// 
// 1     9/04/14 7:56a Anandakrishnanl
// [TAG]  		EIP180861
// [Category]  	Improvement
// [Description]  	Legacy Boot support in Aptio 4.x Nvme driver
// [Files]  		NvmeInt13.cif
// NvmeInt13.c
// NvmeInt13.h
// NvmeInt13.sdl
// NvmeInt13.mak
// NvmeInt13.inf
// NvmeInt13.dxs
// 
//**********************************************************************
//**********************************************************************
//<AMI_FHDR_START>
//
// Name:        NvmeInt13.h
//
// Description: Definitions and structures for NVMe INT13
//
//<AMI_FHDR_END>
//**********************************************************************

#ifndef __NVMEI13_H__
#define __NVMEI13_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <Efi.h>
#include <Protocol/AmiNvmeLegacy.h>
#include "NvmeBus.h"

#define BAID_TYPE_HDD           1
#define BAID_TYPE_RMD_HDD       2
#define BAID_TYPE_CDROM         3
#define BAID_TYPE_RMD_FDD       4
#define BAID_TYPE_FDD           5

#define CSM16_NVME_RT_DID       5

#define SYSTYPE_ATA             0
#define DEVTYPE_SYS             1

// Values for Mass Storage Device type
//-------------------------------------
#define NVME_MASS_DEV_HDD       1
#define MAX_NVME_DEVICES        16
#define NVMEDEVS_MAX_ENTRIES    8

#pragma pack(1)

typedef struct _NVME_MASS_DEV_INFO{
    UINT16      wBlockSize;         
    UINT64      dMaxLba;            
    UINT8       bHeads;             
    UINT8       bSectors;           
    UINT16      wCylinders;         
    UINT8       bNonLBAHeads;       
    UINT8       bNonLBASectors;     
    UINT16      wNonLBACylinders;   
} NVME_MASS_DEV_INFO;

struct _NVME_LEGACY_MASS_DEVICE {
    VOID                    *DevInfo;
    UINT16                  LogicalAddress;
    EFI_HANDLE              Handle;
    UINT16                  PciBDF;
    UINT8                   *DevString;
    UINT8                   StorageType;
};

typedef struct {
    UINT8                   Handle;
    UINT16                  PciBDF;
} NVME_DEV_PCI_LOCATION;


typedef struct {
    UINT8   Handle;
    UINT8   BbsEntryNo;
    UINT8   DevBaidType;
    UINT8   NumHeads;
    UINT8   LBANumHeads;
    UINT16  NumCylinders;
    UINT16  LBANumCyls;
    UINT8   NumSectors;
    UINT8   LBANumSectors;
    UINT16  BytesPerSector;
    UINT8   MediaType;
    UINT64  LastLBA;
    UINT8   BpbMediaDesc;
    UINT8   DeviceNameString[32];
} NVMEMASS_INT13_DEV;

//
// The following data structure is located in NvmeI13.BIN
//
typedef struct {
    NVMEMASS_INT13_DEV          NvmeMassI13Dev[NVMEDEVS_MAX_ENTRIES];
    UINT8                       MfgGenericName[13];    // "NVME Storage", 0
    UINT16                      BcvOffset;
    UINT16                      NvmeSmmDataOffset;
    UINT16                      NvmePciDataOffset;
} NVME_INT13_DATA;

#pragma pack()

EFI_STATUS
NvmeInstallLegacyDevice (
    NVME_LEGACY_MASS_DEVICE            *NvmeLegacyMassDevice
);

EFI_STATUS 
InitInt13RuntimeImage();

/****** DO NOT WRITE BELOW THIS LINE *******/
#ifdef __cplusplus
}
#endif

#endif

//**********************************************************************
//**********************************************************************
//**                                                                  **
//**        (C)Copyright 1985-2014, American Megatrends, Inc.         **
//**                                                                  **
//**                       All Rights Reserved.                       **
//**                                                                  **
//**         5555 Oakbrook Parkway, Suite 200, Norcross, GA 30093     **
//**                                                                  **
//**                       Phone: (770)-246-8600                      **
//**                                                                  **
//**********************************************************************
//**********************************************************************
