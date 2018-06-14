#**********************************************************************
#**********************************************************************
#**                                                                  **
#**        (C)Copyright 1985-2010, American Megatrends, Inc.         **
#**                                                                  **
#**                       All Rights Reserved.                       **
#**                                                                  **
#**      5555 Oakbrook Parkway, Suite 200, Norcross, GA 30093        **
#**                                                                  **
#**                       Phone: (770)-246-8600                      **
#**                                                                  **
#**********************************************************************
#**********************************************************************

#**********************************************************************
# $Header: /Alaska/BIN/Board/Setup/Setup.mak 37    3/02/11 12:06p Felixp $
#
# $Revision: 37 $
#
# $Date: 3/02/11 12:06p $
#**********************************************************************
# Revision History
# ----------------
# $Log: /Alaska/BIN/Board/Setup/Setup.mak $
# 
# 37    3/02/11 12:06p Felixp
# EIP 54915 (Enhancement): 
# Method of generation of the $(BUILD_DIR)\SetupCallbackList.h header is
# changed 
# to support larger number of callbacks(longer value of the
# SETUP_ITEM_CALLBACK_LIST macro) 
# registered under SetupItemCallbacks eLink
# 
# 36    10/06/10 2:34p Felixp
# Make the make file compatible with Core 4.6.4.0
# 
# 35    6/09/10 10:53p Felixp
# Setup Customization Support.
# 
# 34    2/05/10 12:26p Felixp
# 
# 33    2/05/10 11:37a Felixp
# LOGO_FILE_NAME SDL tokens is added to support logo file overrides.
# 
# 32    11/23/09 5:04p Felixp
# Initialize DEFAULT_LANGUAGE_CODE macro based on value of the
# DEFAULT_LANGUAGE token using /D option.
# 
# 31    10/21/09 3:10p Felixp
# UEFI2.1 related: start auto-id generated by VfrId from 1000 to avoid
# conflicts with question ID assigned by VFR compiler
# (requires new version of VfrId)
# 
# 30    10/09/09 6:43p Felixp
# UEFI 2.1 Support (the component is updated to support Framework and
# UEFI 2.1 HII).
# 
# 29    6/30/09 11:42a Robert
# Added Comment and updated parts for coding standards
# 
# 28    5/22/09 6:48p Felixp
# 
# 27    3/05/09 1:23p Felixp
# Improvement:
# Custom commands for the $(BUILD_DIR)\SetupStrTokens.h target are
# replaced with the invocation of the standard (rules.mak based) make
# file.  
# No functionality changes.
# 
# 26    2/23/09 10:16a Oleksiyy
# Bug fix (EIP 18214) Build process failed if too many SetupItemCallbacks
# in one command line. Solution is to
# forward SETUP_ITEM_CALLBACK_LIST definition into SetupCallbackList.h
# file, generated during the build process (in Setup.mak), and include it
# into Setup.c.
# 
# 
# 25    10/30/07 11:24a Felixp
# SDL tokens to hide advanced, chipset, and security formsets added
# 
# 24    9/05/07 12:28p Felixp
# Dependency from $(BUILD_DIR)\AUTOID.h added.
# 
# 23    8/31/07 4:46p Felixp
# Previous changes removed.
# 
# 20    1/22/07 2:58p Felixp
# CJK support added (scan string packs with font tool).
# 
# 19    12/05/06 12:25p Felixp
# Use date/time stamps from TimeStamp.h instead of C __DATE__ macro
# 
# 18    2/06/06 6:30p Felixp
# Support for Callbacks added
# 
# 13    8/23/05 4:07p Felixp
# depndency from token.mak added
# 
# 2     5/31/05 11:20a Felixp
# Advanced and Chipset Screens Disabled
# 
# 5     5/24/05 3:07p Felixp
# Modular setup framework implemented
# 
# 2     3/07/05 7:08p Felixp
# when EMBEDDED_RESOURCES is set to 1, setup will be built as application
# 
#**********************************************************************
#<AMI_FHDR_START>
#
# Name:	Setup.mak
#
# Description:	
#   This file contains the build commands for the setup component.
#
#<AMI_FHDR_END>
#**********************************************************************
all : Setup

SetupData : Setup

SETUP_FORMSETS=\
$(Setup_DIR)\Main.vfr\
$(Setup_DIR)\Advanced.vfr\
$(Setup_DIR)\Chipset.vfr\
$(Setup_DIR)\Boot.vfr\
$(Setup_DIR)\Security.vfr\
$(Setup_DIR)\Exit.vfr

VFR_PACKS_TEMP=$(SETUP_FORMSETS: = $(BUILD_DIR^)\)
VFR_PACKS=$(VFR_PACKS_TEMP:.vfr=.hpk)

!IF $(CORE_COMBINED_VERSION)<262785
Setup : $(BUILD_DIR)\Setup.mak SetupSdbs SetupFiles SetupBin $(BUILD_DIR)\Logo.FFS
!ELSE
PREPARE : $(BUILD_DIR)\Setup.mak SetupSdbs SetupFiles
$(BUILD_DIR)\SetupStrTokens.h : SetupResources
Setup : SetupBin $(BUILD_DIR)\Logo.FFS
!ENDIF

SetupSdbs : 

$(BUILD_DIR)\Setup.mak : $(Setup_DIR)\$(@B).cif $(Setup_DIR)\$(@B).mak $(BUILD_RULES)
	$(CIF2MAK) $(Setup_DIR)\$(@B).cif $(CIF2MAK_DEFAULTS)

SETUP_AUTO_GENERATED_FILES=$(BUILD_DIR)\AUTOID.h $(BUILD_DIR)\LangList.h $(BUILD_DIR)\SetupStrTokens.h
SetupFiles : $(SETUP_AUTO_GENERATED_FILES)

$(BUILD_DIR)\AUTOID.h : $(SETUP_FORMSETS) $(SETUP_DEFINITIONS) $(Setup_DIR)\Setup.mak $(BUILD_DIR)\token.mak
!IF $(EFI_SPECIFICATION_VERSION)>0x20000
	$(VFRID) /s1024 /o$(BUILD_DIR)\AUTOID.h $(SETUP_FORMSETS) $(SETUP_DEFINITIONS)
!ELSE
	$(VFRID) /o$(BUILD_DIR)\AUTOID.h $(SETUP_FORMSETS) $(SETUP_DEFINITIONS)
!ENDIF
	type << >>$(BUILD_DIR)\AUTOID.h
#ifndef AUTO_ID
#define AUTO_ID(x) x
#endif
<<

SETUP_STRGATHER_FLAGS=-db $(BUILD_DIR)\Setup.sdb
!IF "$(SETUP_SDBS)"!=""
SETUP_STRGATHER_FLAGS=$(SETUP_STRGATHER_FLAGS) -db $(SETUP_SDBS: = -db )
!ENDIF

!IF $(CORE_COMBINED_VERSION)<262785
$(BUILD_DIR)\SetupStrTokens.h : $(SETUP_FORMSETS) $(SETUP_DEFINITIONS) $(SETUP_SDBS) $(Setup_DIR)\Setup.mak $(Setup_DIR)\Setup.uni $(BUILD_DIR)\token.mak
	$(MAKE) /$(MAKEFLAGS) $(BUILD_DEFAULTS) TYPE=SDB\
		/f $(BUILD_DIR)\Setup.mak all
	$(MAKE) /$(MAKEFLAGS) /a $(BUILD_DEFAULTS) TYPE=SDB\
        STRING_CONSUMERS= "STRGATHER_FLAGS=$(SETUP_STRGATHER_FLAGS)"\
		/f $(BUILD_DIR)\Setup.mak $(BUILD_DIR)\SetupStrTokens.h
!ELSE
SetupResources : $(SETUP_FORMSETS) $(SETUP_DEFINITIONS) $(SETUP_SDBS) $(Setup_DIR)\Setup.mak $(Setup_DIR)\Setup.uni $(BUILD_DIR)\token.mak
	$(MAKE) /$(MAKEFLAGS) $(NO_EXT_OBJS_BUILD_DEFAULTS) TYPE=SDB\
		/f $(BUILD_DIR)\Setup.mak all
	$(MAKE) /$(MAKEFLAGS) /a $(NO_EXT_OBJS_BUILD_DEFAULTS) TYPE=RESOURCES\
        "STRGATHER_FLAGS=$(SETUP_STRGATHER_FLAGS)"\
		"VFR_PACKS=$(BUILD_DIR)\SetupStr.hpk $(VFR_PACKS)"\
!IF "$(SETUP_DATA_LAYOUT_OVERRIDE_HEADER)"==""
		"VFR_INCLUDES=$(SETUP_VFR_INCLUDES)"\
!ELSE
		"VFR_INCLUDES=$(SETUP_VFR_INCLUDES) -t $(SETUP_DATA_LAYOUT_OVERRIDE_HEADER)"\
!ENDIF
		/f $(BUILD_DIR)\Setup.mak all
!ENDIF # !IF $(CORE_COMBINED_VERSION)<262785

_INCLUDE=!INCLUDE
_IF=!IF
_ENDIF=!ENDIF
_ERROR=!ERROR
_MESSAGE=!MESSAGE
$(BUILD_DIR)\LangList.h : $(BUILD_DIR)\token.mak $(Setup_DIR)\Setup.mak Core\Languages.mak
    $(ECHO) // Supported Languages > $(BUILD_DIR)\LangList.h
	$(MAKE) EFI_SPECIFICATION_VERSION=0x20000 FORMAT_NAME=Iso6392 -f<<$(BUILD_DIR)\LangList.mak
$(_INCLUDE) $(BUILD_DIR)\token.mak
$(_INCLUDE) Core\Languages.mak
COMMA_SEPARATED_LIST=$$(SUPPORTED_LANGUAGES: =,),
$(_IF) "$$(COMMA_SEPARATED_LIST:,,=x)"!="$$(COMMA_SEPARATED_LIST)"
$(_MESSAGE) Potential problems: 
$(_MESSAGE) - The token is blank
$(_MESSAGE) - More than one space between language names
$(_MESSAGE) - One of the language names is not in $$$$(<lang-name>) format 
$(_MESSAGE) - One of the language names is not defined in the ISO 639-2 section of Core\Languages.mak
$(_MESSAGE) - One of the language names is not defined in the RFC 4646 section of Core\Languages.mak
$(_ERROR) Invalid format of the SUPPORTED_LANGUAGES token
$(_ENDIF)
all : 
 $(ECHO) static CHAR8* $$(FORMAT_NAME)LanguageList[] = {"$$(SUPPORTED_LANGUAGES: =", ")", NULL}; >> $@
<<KEEP
    $(MAKE) EFI_SPECIFICATION_VERSION=0x2000A FORMAT_NAME=Rfc4646 -f $(BUILD_DIR)\LangList.mak
!UNDEF _INCLUDE
!UNDEF _IF
!UNDEF _ENDIF
!UNDEF _ERROR
!UNDEF _MESSAGE

SetupBin : $(AMIDXELIB)
	$(SILENT)type << >$(BUILD_DIR)\SetupCallbackList.h
#define SETUP_ITEM_CALLBACK_LIST $(SetupItemCallbacks)
<<
	$(MAKE) /$(MAKEFLAGS) $(BUILD_DEFAULTS)\
		/f $(BUILD_DIR)\Setup.mak all\
		GUID=899407D7-99FE-43d8-9A21-79EC328CAC21\
		ENTRY_POINT=SetupEntry\
        "MY_DEFINES=/DDEFAULT_LANGUAGE_CODE=$(DEFAULT_LANGUAGE)"\
		TYPE=BS_DRIVER SDB_FILES=\
		"VFR_PACKS=$(BUILD_DIR)\SetupStr.hpk $(VFR_PACKS)"\
!IF $(CORE_COMBINED_VERSION)<262785
		"VFR_INCLUDES=$(SETUP_VFR_INCLUDES)" COMPRESS=1\
!ELSE
		COMPRESS=1\
!ENDIF
		"EXT_HEADERS=$(SETUP_AUTO_GENERATED_FILES) $(BUILD_DIR)\TimeStamp.h $(BUILD_DIR)\token.h"\
		"INIT_LIST=$(SetupStringInit)"

$(BUILD_DIR)\Logo.ffs : $(LOGO_FILE_NAME)
	$(MAKE) /f Core\FFS.mak \
	BUILD_DIR=$(BUILD_DIR) \
# Don't change the GUID. ChangeLogo expects this GUID.
	GUID=7BB28B99-61BB-11D5-9A5D-0090273FC14D \
	TYPE=EFI_FV_FILETYPE_FREEFORM \
	BINFILE=$** FFSFILE=$@ COMPRESS=1 NAME=$(**B)



#**********************************************************************
#**********************************************************************
#**                                                                  **
#**        (C)Copyright 1985-2010, American Megatrends, Inc.         **
#**                                                                  **
#**                       All Rights Reserved.                       **
#**                                                                  **
#**      5555 Oakbrook Parkway, Suite 200, Norcross, GA 30093        **
#**                                                                  **
#**                       Phone: (770)-246-8600                      **
#**                                                                  **
#**********************************************************************
#**********************************************************************
