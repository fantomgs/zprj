
        TITLE   OEM16SIG.ASM - The OEM signature definition file

;**********************************************************************
;**********************************************************************
;**                                                                  **
;**        (C)Copyright 1985-2010, American Megatrends, Inc.         **
;**                                                                  **
;**                       All Rights Reserved.                       **
;**                                                                  **
;**           5555 Oakbrook Pkwy, Suite 200, Norcross, GA 30093      **
;**                                                                  **
;**                       Phone: (770)-246-8600                      **
;**                                                                  **
;**********************************************************************
;**********************************************************************

;****************************************************************************
; $Header: /Alaska/SOURCE/Modules/CSM/Generic/OEM Hooks/oem16sig.asm 2     1/12/10 11:50a Olegi $
;
; $Revision: 2 $
;
; $Date: 1/12/10 11:50a $
;****************************************************************************

OEM16SIG_CSEG SEGMENT PARA PUBLIC 'CODE' USE16

    db  "$OEM$FUN"

OEM16SIG_CSEG ENDS

END

;**********************************************************************
;**********************************************************************
;**                                                                  **
;**        (C)Copyright 1985-2010, American Megatrends, Inc.         **
;**                                                                  **
;**                       All Rights Reserved.                       **
;**                                                                  **
;**           5555 Oakbrook Pkwy, Suite 200, Norcross, GA 30093      **
;**                                                                  **
;**                       Phone: (770)-246-8600                      **
;**                                                                  **
;**********************************************************************
;**********************************************************************
