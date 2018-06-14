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
# $Header: /Alaska/BIN/Modules/Network/UEFINetworkStack II/Common/Tcp/Tcp.mak 2     5/01/12 10:09a Hari $
#
# Revision: $
#
# $Date: 5/01/12 10:09a $
#**********************************************************************
# Revision History
# ----------------
# 
#**********************************************************************
#<AMI_FHDR_START>
#
# Name:	Tcp6.mak
#
# Description:	
#
#<AMI_FHDR_END>
#**********************************************************************
all : Tcp

Tcp : $(BUILD_DIR)\Tcp.ffs

!IF "$(x64_BUILD)"=="1"
$(BUILD_DIR)\Tcp.ffs : $(Tcp_DIR)\TcpDxe.efi
!ELSE
$(BUILD_DIR)\Tcp.ffs : $(Tcp_DIR)\TcpDxeIa32.efi
!ENDIF
	$(MAKE) /f Core\FFS.mak \
	BUILD_DIR=$(BUILD_DIR) \
	GUID=B1625D3C-9D2D-4e0d-B864-8A763EE4EC50\
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