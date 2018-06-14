//****************************************************************************
//****************************************************************************
//**                                                                        **
//**         (C)Copyright 1985-2012, American Megatrends, Inc.              **
//**                                                                        **
//**                          All Rights Reserved.                          **
//**                                                                        **
//**         5555 Oakbrook Parkway, Suite 200, Norcross, GA 30093           **
//**                                                                        **
//**                          Phone (770)-246-8600                          **
//**                                                                        **
//****************************************************************************
//****************************************************************************
//****************************************************************************
//**********************************************************************
// $Header: /Alaska/SOURCE/Modules/SharkBayRefCodes/SwitchableGraphics/Sg TPV/Sg Acpi Tables/SgTpvPEG/NvSSDT.asl 2     2/21/13 5:37a Joshchou $
//
// $Revision: 2 $
//
// $Date: 2/21/13 5:37a $
//**********************************************************************
// Revision History
// ----------------
// $Log: /Alaska/SOURCE/Modules/SharkBayRefCodes/SwitchableGraphics/Sg TPV/Sg Acpi Tables/SgTpvPEG/NvSSDT.asl $
// 
// 2     2/21/13 5:37a Joshchou
// [TAG]  		EIP106524
// [Category]  	New Feature
// [Description]  	Support GC6 function for Optimus.
// 
// 1     1/15/13 5:58a Joshchou
// [TAG]  		None
// [Category]  	Improvement
// [Description]  	Create componet for SG support on PEG
// [Files]  		SgNvidia.cif
// NvSSDT.asl
// NVdGPU.asl
// NViGPU.asl
// NViGDmisc.asl
// OpSSDT.asl
// NvVentura.asl
// NvGPS.asl
// 
// 2     9/09/12 11:04p Joshchou
// [TAG]  		EIPNone
// [Category]  	Improvement
// [Description]  	Tpv module support for sharkbay.
// [Files]  		NvSSDT.asl
// NVdGPU.asl
// NViGPU.asl
// NViGDmisc.asl
// OpSSDT.asl
// NvVentura.asl
// NvGPS.asl
// 
// 5     12/22/11 6:31a Alanlin
// Declared "defined(SGTPV_ASL_DEBUG) && (SGTPV_ASL_DEBUG ==1)"
// 
// 
// 3     12/02/11 12:38a Alanlin
// [TAG]  		EIP75359
// [Category]  	Improvement
// [Description]  	Report _STA asl method to PCIe root port for nVidia
// GPU.
// 
// 2     10/14/11 2:59a Alanlin
// [TAG]  		EIP64451
// [Category]  	New Feature
// [Description]  	Optimus GPS feature update 
// [Files]  		NvSSDT.asl
// NViGPU.asl
// OpSSDT.asl
// NvGPS.asl
// SgNvidia.cif
// 
// 1     6/27/11 5:27a Alanlin
// [TAG]  		EIP61848
// [Category]  	New Feature
// [Description]  	Initial check-in.Integrated SwitchableGraphics Intel
// Reference code 0.6.0
// [Files]  		SgNvidia.cif
// NvSSDT.asl
// NVdGPU.asl
// NViGPU.asl
// NViGDmisc.asl
// OpSSDT.asl
// NvVentura.asl
// 
// 
// 5     3/17/11 6:17p Alexp
// Optimus:Add code to preserve HD AudioCodec enable flag in CMOS
// 
// 4     11/12/10 1:25p Alexp
// rename ELCT to ELCL in order to avoid name conflict with Intel's ref
// code in SgDGPU.asl
// 
// 3     10/06/10 3:34p Alexp
// Include defines for different Nvidia GUID functions. Helps to control
// inclusion of peices of ASL depending on type of desired SG mode
// 
// 2     10/05/10 7:14p Alexp
// 1. Added debug macro to be able to insert check points in target ASL
// code
// 2. Reuse NVdGPU.asl file to build OpSSDT for Optimus and NvSSDT for
// MUXed SG targets.
//     NvOptimus.asl no longer required
// 
// 1     9/17/10 1:21p Alexp
// [TAG]    	  EIP43103 
// [Category]  Function Request
// [Severity]	  Normal
// [Symptom]    Initial check-in of SgTPV module
// [RootCause] Request to implement SG reference code .
// [Solution]	Initial check-in. 
// [Files]	
//         SgNvidia.cif;
//         NvSSDT.asl; NVdGPU.asl;NViGPU.asl;NViGDmisc
//         OpSSDT.asl;NvOptimus.asl;NvVenture.asl
// 
// 
//**********************************************************************

DefinitionBlock (
        "Nvidia.aml",
        "SSDT",
        1,
        "NvdRef",
        "NvdTabl",
        0x1000
        ) {       

#define HYBRID_DSM_GUID 1
#define MXM_DSM_GUID 1
//#define NBCI_DSM_GUID 1

External(P8XH, MethodObj)

#if defined(SGTPV_ASL_DEBUG) && (SGTPV_ASL_DEBUG ==1)
#define P8DB(arg0, arg1, arg2) P8XH (0, arg1) P8XH (1, arg0) sleep(arg2)
#else
#define P8DB(arg0, arg1, arg2) 
#endif

External(PCI_SCOPE, DeviceObj)
External(PEG_SCOPE, DeviceObj)
External(DGPU_SCOPE, DeviceObj)
External(IGPU_SCOPE, DeviceObj)
External(DGPU_SCOPE._ADR, DeviceObj)
External(IGPU_SCOPE._DSM, MethodObj)
External(DGPU_SCOPE.SGST, MethodObj)
External(DGPU_SCOPE.SGON, MethodObj)
External(DGPU_SCOPE.SGOF, MethodObj)
External(DGPU_SCOPE.SGPI, MethodObj)
External(DGPU_SCOPE.SGPO, MethodObj)
External(\DSEL)
External(\ESEL)
External(\SSEL)
External(\PSEL)
External(\HLRS)
External(\PWEN)
External(\PWOK)
External(\SGMD)
External(\SGFL)
External(\SSMP)


#include <NVdGPU.ASL>     // Include DGPU device namespace
#include <NViGPU.ASL>     // Include NVHG DSM calls
#include <NViGDmisc.ASL>  // Include misc event callback methods
#if NV_VENTURA_SUPPORT == 1
#include <NvVentura.ASL>  // Include Ventura support
#endif
#if NV_GPS_SUPPORT == 1
#include <NvGPS.ASL>  // Include GPS support
#endif
#if NV_GC6_SUPPORT == 1
#include <NvGC6.ASL>  // Include GC6 support
#endif

Scope(PEG_SCOPE) 
{
	Method(_STA,0,Serialized)
	{
			Return(0x000F)
        }
}
Scope(PCI_SCOPE) 
{
//<AMI_PHDR_START>
//------------------------------------------------------------------------
//
// Procedure:    WMI1
//
// Description:  WMI MXM Mapper. ASL Device is used to acccess Mxm native method via WMI API
//
//-------------------------------------------------------------------------
//<AMI_PHDR_END> 
    Device(WMI1) // placed within PCI Bus scope parallel to iGPU 
    { 
        Name(_HID, "PNP0C14")
        Name(_UID, "MXM2")    
   
        Name(_WDG, Buffer() 
        {
            // Methods GUID {F6CB5C3C-9CAE-4ebd-B577-931EA32A2CC0}
            0x3C, 0x5C, 0xCB, 0xF6, 0xAE, 0x9C, 0xbd, 0x4e, 0xB5, 0x77, 0x93, 0x1E,
            0xA3, 0x2A, 0x2C, 0xC0,
            0x4D, 0x58, // Object ID "MX" = method "WMMX"
            1,          // Instance Count
            0x02,       // Flags (WMIACPI_REGFLAG_METHOD)

            // NVHG_NOTIFY_POLICYCHANGE 
            // WMI Notify - Hybrid Policy Request D0
            // GUID {921A2F40-0DC4-402d-AC18-B48444EF9ED2}
            0x40, 0x2F, 0x1A, 0x92, 0xC4, 0x0D, 0x2D, 0x40, 0xAC, 0x18, 0xB4, 0x84, 0x44, 0xEF, 0x9E, 0xD2,
            0xD0, 0x00, 0x01, 0x08,

            // NVHG_NOTIFY_POLICYSET
            // WMI Notify D9 - Hybrid Policy Set 
            // GUID  {C12AD361-9FA9-4C74-901F-95CB0945CF3E}
            0x61, 0xD3, 0x2A, 0xC1, 0xA9, 0x9F, 0x74, 0x4C, 0x90, 0x1F, 0x95, 0xCB, 0x09, 0x45, 0xCF, 0x3E,
            0xD9, 0x00, 0x01, 0x08,

            // NVHG_DISPLAY_SCALING
            // Notify event DB - Display scaling change
            // GUID {42848006-8886-490E-8C72-2BDCA93A8A09}
            0x06, 0x80, 0x84, 0x42, 0x86, 0x88, 0x0E, 0x49, 0x8C, 0x72, 0x2B, 0xDC, 0xA9, 0x3A, 0x8A, 0x09,
            0xDB, 0x00, 0x01, 0x08,

            // NVHG_DISPLAY_HOTKEY, ACPI_NOTIFY_PANEL_SWITCH GUID
            // Notify event 80 (fixed) - Hot-Key, use _DGS, _DCS etc. 
            // GUID {E06BDE62-EE75-48F4-A583-B23E69ABF891}
            0x62, 0xDE, 0x6B, 0xE0, 0x75, 0xEE, 0xF4, 0x48, 0xA5, 0x83, 0xB2, 0x3E, 0x69, 0xAB, 0xFB, 0x91,
            0x80, 0x00, 0x01, 0x08,

            // NVHG_DISPLAY_HOTplug, ACPI_NOTIFY_DEVICE_HOTPLUG
            // Notify event 81 (fixed) - Hot-Plug, query _DCS 
            // GUID {3ADEBD0F-0C5F-46ED-AB2E-04962B4FDCBC}
            0x0F, 0xBD, 0xDe, 0x3A, 0x5F, 0x0C, 0xED, 0x46, 0xAB, 0x2E, 0x04, 0x96, 0x2B, 0x4F, 0xDC, 0xBC,
            0x81, 0x00, 0x01, 0x08,

            // NVHG_BRIGHTNESS_INC, ACPI_NOTIFY_INC_BRIGHTNESS_HOTKEY
            // Notify event 86 (fixed) - Backlight Increase 
            // GUID {1E519311-3E75-4208-B05E-EBE17E3FF41F}
            0x11, 0x93, 0x51, 0x1E, 0x75, 0x3E, 0x08, 0x42, 0xB0, 0x5E, 0xEB, 0xE1, 0x7E, 0x3F, 0xF4, 0x1F,
            0x86, 0x00, 0x01, 0x08,

            // NVHG_BRIGHTNESS_DEC, ACPI_NOTIFY_DEC_BRIGHTNESS_HOTKEY
            // Notify event 87 (fixed) - Backlight Decrease 
            // GUID {37F85341-4418-4F24-8533-38FFC7295542}
            0x41, 0x53, 0xF8, 0x37, 0x18, 0x44, 0x24, 0x4F, 0x85, 0x33, 0x38, 0xFF, 0xC7, 0x29, 0x55, 0x42,
            0x87, 0x00, 0x01, 0x08,

            // MOF data {05901221-D566-11d1-B2F0-00A0C9062910}
            0x21, 0x12, 0x90, 0x05, 0x66, 0xd5, 0xd1, 0x11, 0xb2, 0xf0,
            0x00, 0xa0, 0xc9, 0x06, 0x29, 0x10,
            0x58, 0x4D, // Object ID "XM"
            1,          // Instance Count = 1
            0x00       // Flags
        }
        ) // End of _WDG

//<AMI_PHDR_START>
//------------------------------------------------------------------------
//
// Procedure:    WMMX
//
// Description:  WMI Method execution tunnel. MXM Native methods are called via WMMX index.
//
// Input:
//          Arg1:   Integer     GPU index. 0x10-iGPU, 0x0-0xf - dGPU
//
//  Output:
//          Buffer      specific to the funcion being called
//-------------------------------------------------------------------------
//<AMI_PHDR_END> 
        Method(WMMX, 3)
        {

            //Arg1 = 0x10 indicates iGPU, 0x0~0x0F for dgpu
            CreateDwordField(Arg2, 0, FUNC)                 // Get the function name
            If (LEqual(FUNC, 0x4D53445F))                   // "_DSM"
            {
                If (LGreaterEqual(SizeOf(Arg2), 28))
                {
                    CreateField(Arg2, 0, 128, MUID)
                    CreateDwordField(Arg2, 16, REVI)
                    CreateDwordField(Arg2, 20, SFNC)
                    CreateField(Arg2, 0xe0, 0x20, XRG0)
                    
                    If(LNotEqual(Arg1,0x10))          
                    {
                        If (CondRefOf(IGPU_SCOPE._DSM)) // common with dGPU DSM functions
                        {
                            Return(IGPU_SCOPE._DSM(MUID, REVI, SFNC, XRG0))
                        }
                    }
                }
            }            
            
            ElseIf (LEqual(FUNC, 0x584D584D))     // "MXMX"
            {
                CreateDWordField(Arg2, 8, XRG1)
                If (LEqual(Arg1, 0x10))
                {
                    Return(IGPU_SCOPE.MXMX(XRG1))
                }
                Else
                {
                    Return(DGPU_SCOPE.MXMX(XRG1))   
                }
            }
            
            ElseIf (LEqual(FUNC, 0x5344584D))     // "MXDS"
            {
                CreateDWordField(Arg2, 8, XRG2)
                If (LEqual(Arg1, 0x10))
                {
                    Return(IGPU_SCOPE.MXDS(XRG2))
                }
                Else
                {
                    Return(DGPU_SCOPE.MXDS(XRG2))   
                }
            }
            Return(0)
        } // End of WMMX

        Name(WQXM, Buffer() 
        {
            0x46,0x4F,0x4D,0x42,0x01,0x00,0x00,0x00,0x8B,0x02,0x00,0x00,0x0C,0x08,0x00,0x00,
            0x44,0x53,0x00,0x01,0x1A,0x7D,0xDA,0x54,0x18,0xD2,0x83,0x00,0x01,0x06,0x18,0x42,
            0x10,0x05,0x10,0x8A,0xE6,0x80,0x42,0x04,0x92,0x43,0xA4,0x30,0x30,0x28,0x0B,0x20,
            0x86,0x90,0x0B,0x26,0x26,0x40,0x04,0x84,0xBC,0x0A,0xB0,0x29,0xC0,0x24,0x88,0xFA,
            0xF7,0x87,0x28,0x09,0x0E,0x25,0x04,0x42,0x12,0x05,0x98,0x17,0xA0,0x5B,0x80,0x61,
            0x01,0xB6,0x05,0x98,0x16,0xE0,0x18,0x92,0x4A,0x03,0xA7,0x04,0x96,0x02,0x21,0xA1,
            0x02,0x94,0x0B,0xF0,0x2D,0x40,0x3B,0xA2,0x24,0x0B,0xB0,0x0C,0x23,0x02,0x8F,0x82,
            0xA1,0x71,0x68,0xEC,0x30,0x2C,0x13,0x4C,0x83,0x38,0x8C,0xB2,0x91,0x45,0x60,0xDC,
            0x4E,0x05,0xC8,0x15,0x20,0x4C,0x80,0x78,0x54,0x61,0x34,0x07,0x45,0xE0,0x42,0x63,
            0x64,0x40,0xC8,0xA3,0x00,0xAB,0xA3,0xD0,0xA4,0x12,0xD8,0xBD,0x00,0x8D,0x02,0xB4,
            0x09,0x70,0x28,0x40,0xA1,0x00,0x6B,0x18,0x72,0x06,0x21,0x5B,0xD8,0xC2,0x68,0x50,
            0x80,0x45,0x14,0x8D,0xE0,0x2C,0x2A,0x9E,0x93,0x50,0x02,0xDA,0x1B,0x82,0xF0,0x8C,
            0xD9,0x18,0x9E,0x10,0x83,0x54,0x86,0x21,0x88,0xB8,0x11,0x8E,0xA5,0xFD,0x41,0x10,
            0xF9,0xAB,0xD7,0xB8,0x1D,0x69,0x34,0xA8,0xB1,0x26,0x38,0x76,0x8F,0xE6,0x84,0x3B,
            0x17,0x20,0x7D,0x6E,0x02,0x39,0xBA,0xD3,0xA8,0x73,0xD0,0x64,0x78,0x0C,0x2B,0xC1,
            0x7F,0x80,0x4F,0x01,0x78,0xD7,0x80,0x9A,0xFE,0xC1,0x33,0x41,0x70,0xA8,0x21,0x7A,
            0xD4,0xE1,0x4E,0xE0,0xBC,0x8E,0x84,0x41,0x1C,0xD1,0x71,0x63,0x67,0x75,0x32,0x07,
            0x5D,0xAA,0x00,0xB3,0x07,0x00,0x0D,0x2E,0xC1,0x69,0x9F,0x49,0xE8,0xF7,0x80,0xF3,
            0xE9,0x79,0x6C,0x6C,0x10,0xA8,0x91,0xF9,0xFF,0x0F,0xED,0x41,0x9E,0x56,0xCC,0x90,
            0xCF,0x02,0x87,0xC5,0xC4,0x1E,0x19,0xE8,0x78,0xC0,0x7F,0x00,0x78,0x34,0x88,0xF0,
            0x66,0xE0,0xF9,0x9A,0x60,0x50,0x08,0x39,0x19,0x0F,0x4A,0xCC,0xF9,0x80,0xCC,0x25,
            0xC4,0x43,0xC0,0x31,0xC4,0x08,0x7A,0x46,0x45,0x23,0x6B,0x22,0x3E,0x03,0x78,0xDC,
            0x96,0x05,0x42,0x09,0x0C,0xEC,0x73,0xC3,0x3B,0x84,0x61,0x71,0xA3,0x09,0xEC,0xF3,
            0x85,0x05,0x0E,0x0A,0x05,0xEB,0xBB,0x42,0xCC,0xE7,0x81,0xE3,0x3C,0x60,0x0B,0x9F,
            0x28,0x01,0x3E,0x24,0x8F,0x06,0xDE,0x20,0xE1,0x5B,0x3F,0x02,0x10,0xE0,0x27,0x06,
            0x13,0x58,0x1E,0x30,0x7A,0x94,0xF6,0x2B,0x00,0x21,0xF8,0x8B,0xC5,0x53,0xC0,0xEB,
            0x40,0x84,0x63,0x81,0x29,0x72,0x6C,0x68,0x78,0x7E,0x70,0x88,0x1E,0xF5,0x5C,0xC2,
            0x1F,0x4D,0x94,0x53,0x38,0x1C,0x1F,0x39,0x8C,0x10,0xFE,0x49,0xE3,0xC9,0xC3,0x9A,
            0xEF,0x00,0x9A,0xD2,0x5B,0xC0,0xFB,0x83,0x47,0x80,0x11,0x20,0xE1,0x68,0x82,0x89,
            0x7C,0x3A,0x01,0xD5,0xFF,0xFF,0x74,0x02,0xB8,0xBA,0x01,0x14,0x37,0x6A,0x9D,0x49,
            0x7C,0x2C,0xF1,0xAD,0xE4,0xBC,0x43,0xC5,0x7F,0x93,0x78,0x3A,0xF1,0x34,0x1E,0x4C,
            0x42,0x44,0x89,0x18,0x21,0xA2,0xEF,0x27,0x46,0x08,0x15,0x31,0x6C,0xA4,0x37,0x80,
            0xE7,0x13,0xE3,0x84,0x08,0xF4,0x74,0xC2,0x42,0x3E,0x34,0xA4,0xE1,0x74,0x02,0x50,
            0xE0,0xFF,0x7F,0x3A,0x81,0x1F,0xF5,0x74,0x82,0x1E,0xAE,0x4F,0x19,0x18,0xE4,0x03,
            0xF2,0xA9,0xC3,0xF7,0x1F,0x13,0xF8,0x78,0xC2,0x45,0x1D,0x4F,0x50,0xA7,0x07,0x1F,
            0x4F,0xD8,0x19,0xE1,0x2C,0x1E,0x03,0x7C,0x3A,0xC1,0xDC,0x13,0x7C,0x3A,0x01,0xDB,
            0x68,0x60,0x1C,0x4F,0xC0,0x77,0x74,0xC1,0x1D,0x4F,0xC0,0x30,0x18,0x18,0xE7,0x13,
            0xE0,0x31,0x5E,0xDC,0x31,0xC0,0x43,0xE0,0x03,0x78,0xDC,0x38,0x3D,0x2B,0x9D,0x14,
            0xF2,0x24,0xC2,0x07,0x85,0x39,0xB0,0xE0,0x14,0xDA,0xF4,0xA9,0xD1,0xA8,0x55,0x83,
            0x32,0x35,0xCA,0x34,0xA8,0xD5,0xA7,0x52,0x63,0xC6,0xCE,0x19,0x0E,0xF8,0x10,0xD0,
            0x89,0xC0,0xF2,0x9E,0x0D,0x02,0xB1,0x0C,0x0A,0x81,0x58,0xFA,0xAB,0x45,0x20,0x0E,
            0x0E,0xA2,0xFF,0x3F,0x88,0x23,0xD2,0x0A,0xC4,0xFF,0x7F,0x7F
        }
        ) // End of WQXM
     } // End of WMI1 Device
  } // end scope PCI0
} // end SSDT   
//**********************************************************************
//**********************************************************************
//**********************************************************************
//**                                                                  **
//**        (C)Copyright 1985-2012, American Megatrends, Inc.         **
//**                                                                  **
//**                       All Rights Reserved.                       **
//**                                                                  **
//**        5555 Oakbrook Pkwy, Suite 200, Norcross, GA 30093         **
//**                                                                  **
//**                       Phone: (770)-246-8600                      **
//**                                                                  **
//**********************************************************************
//**********************************************************************