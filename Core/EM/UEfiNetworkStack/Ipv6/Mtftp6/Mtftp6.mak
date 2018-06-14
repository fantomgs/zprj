#//**********************************************************************
#//**********************************************************************
#//**                                                                  **
#//**        (C)Copyright 1985-2008, American Megatrends, Inc.         **
#//**                                                                  **
#//**                       All Rights Reserved.                       **
#//**                                                                  **
#//**         5555 Oakbrook Pkwy, Suite 200, Norcross, GA 30093        **
#//**                                                                  **
#//**                       Phone: (770)-246-8600                      **
#//**                                                                  **
#//**********************************************************************
#//**********************************************************************

#**********************************************************************
# $Header: /Alaska/BIN/Modules/Network/UEFINetworkStack II/IPV6/MtFtp6/Mtftp6.mak 2     5/01/12 11:24a Hari $
#
# Revision: $
#
# $Date: 5/01/12 11:24a $
#**********************************************************************
# Revision History
# ----------------
# 
#**********************************************************************
#<AMI_FHDR_START>
#
# Name:	Mtftp6.mak
#
# Description:	
#
#<AMI_FHDR_END>
#**********************************************************************
all : Mtftp6

Mtftp6 : $(BUILD_DIR)\Mtftp6.ffs

!IF "$(x64_BUILD)"=="1"
$(BUILD_DIR)\Mtftp6.ffs : $(Mtftp6_DIR)\Mtftp6Dxe.efi
!ELSE
$(BUILD_DIR)\Mtftp6.ffs : $(Mtftp6_DIR)\Mtftp6DxeIa32.efi
!ENDIF
	$(MAKE) /f Core\FFS.mak \
	BUILD_DIR=$(BUILD_DIR) \
	GUID=61AFA251-8AC8-4440-9AB5-762B1BF05156\
	TYPE=EFI_FV_FILETYPE_DRIVER \
	PEFILE=$** FFSFILE=$@ COMPRESS=1 NAME=$(**B)
#**********************************************************************
#**                                                                  **
#**        (C)Copyright 1985-2004, American Megatrends, Inc.         **
#**                                                                  **
#**                       All Rights Reserved.                       **
#**                                                                  **
#**             6145-F Northbelt Pkwy, Norcross, GA 30071            **
#**                                                                  **
#**                       Phone: (770)-246-8600                      **
#**                                                                  **
#**********************************************************************
#**********************************************************************