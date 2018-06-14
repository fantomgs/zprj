/** @file
  Intializes all include B0 Hsio structures

@copyright
  Copyright (c) 2013 Intel Corporation. All rights reserved
  This software and associated documentation (if any) is furnished
  under a license and may only be used or copied in accordance
  with the terms of the license. Except as permitted by such
  license, no part of this software or documentation may be
  reproduced, stored in a retrieval system, or transmitted in any
  form or by any means without the express written consent of
  Intel Corporation.

  This file contains an 'Intel Peripheral Driver' and uniquely
  identified as "Intel Reference Module" and is
  licensed for Intel CPUs and chipsets under the terms of your
  license agreement with Intel or your vendor.  This file may
  be modified by the user, subject to additional terms of the
  license agreement

**/

#include "PchHsio.h"

#ifdef TRAD_FLAG

UINT8 PchChipsetInitTableLptH_B0[] = {
  0x79, 0x56, //U16 CRC-16
  0x23, 0x02, //U16 Version
  0x1A,       //U8 NumEntries
  // Hsio Entries
  // Offset   Value                 EP
  0x40,0xC1, 0xA6,0x05,0x08,0x00, 0xEB,
  0x44,0xC1, 0x94,0x03,0x04,0x00, 0xEB,
  0x40,0x83, 0x96,0x05,0x08,0x00, 0xE9,
  0x40,0x83, 0x96,0x05,0x08,0x00, 0xEA,
  0x44,0x83, 0x94,0x03,0x04,0x00, 0xE9,
  0x44,0x83, 0x94,0x03,0x04,0x00, 0xEA,
  0x0C,0x80, 0x50,0xAB,0x02,0x0E, 0xEB,
  0x0C,0x80, 0x50,0xAB,0x02,0x0E, 0xE9,
  0x00,0xC1, 0x89,0x5F,0x0B,0x0F, 0xEB,
  0x00,0xC1, 0x89,0x5F,0x0B,0x0F, 0xE9,
  0x7C,0xC1, 0x00,0x3F,0x40,0x3D, 0xEB,
  0x7C,0xC1, 0x00,0x3F,0x00,0x4F, 0xE9,
  0x78,0xC1, 0x84,0x1B,0x00,0x00, 0xE9,
  0xCC,0xC1, 0x04,0x43,0x35,0x00, 0xEB,
  0x90,0xC0, 0x55,0x51,0x3E,0x2B, 0xE9,
  0x90,0x82, 0x55,0x51,0x3E,0x2B, 0xEA,
  0x8C,0xC0, 0x46,0x20,0x78,0x0C, 0xE9,
  0x8C,0x82, 0x46,0x20,0x78,0x0C, 0xEA,
  0x30,0xC0, 0x00,0x0F,0x00,0x00, 0xEB,
  0x30,0xC0, 0x00,0x0F,0x00,0x00, 0xE9,
  0x30,0xC0, 0x00,0x0F,0x00,0x00, 0xEA,
  0xCC,0xC1, 0x04,0x43,0x35,0x00, 0xE9,
  0xCC,0xC1, 0x04,0x43,0x35,0x00, 0xEA,
  0x2C,0xC0, 0x00,0x0A,0x00,0x0F, 0xEB,
  0x2C,0x82, 0x00,0x0A,0x00,0x0F, 0xE9,
  0x2C,0x82, 0x00,0x0A,0x00,0x0F, 0xEA
};

IOBP_MMIO_TABLE_STRUCT PchSataHsioLptH_B0[] = {
  { 0xEA008008, (UINT32)~(0xFF000000), 0x1C000000 },
  { 0xEA00800C, (UINT32)~(0x00007FFF), 0x00002B50 },
  { 0xEA0024A4, (UINT32)~(0x0030FF00), 0x00308300 },
  { 0xEA0026A4, (UINT32)~(0x0030FF00), 0x00308300 },
  { 0xEA0008A4, (UINT32)~(0x0030FF00), 0x00308300 },
  { 0xEA000AA4, (UINT32)~(0x0030FF00), 0x00308300 },
  { 0xEA0024AC, (UINT32)~(0x00000030), 0x00000020 },
  { 0xEA0026AC, (UINT32)~(0x00000030), 0x00000020 },
  { 0xEA0008AC, (UINT32)~(0x00000030), 0x00000020 },
  { 0xEA000AAC, (UINT32)~(0x00000030), 0x00000020 },
  { 0xEA002488, (UINT32)~(0x0000FF00), 0x00008000 },
  { 0xEA002688, (UINT32)~(0x0000FF00), 0x00008000 },
  { 0xEA000888, (UINT32)~(0x0000FF00), 0x00008000 },
  { 0xEA000A88, (UINT32)~(0x0000FF00), 0x00008000 },
  { 0xEA002494, (UINT32)~(0x80000000), 0x80000000 },
  { 0xEA002694, (UINT32)~(0x80000000), 0x80000000 },
  { 0xEA000894, (UINT32)~(0x80000000), 0x80000000 },
  { 0xEA000A94, (UINT32)~(0x80000000), 0x80000000 },
  { 0xEA002540, (UINT32)~(0x00FFFFFF), 0x00180918 },
  { 0xEA002740, (UINT32)~(0x00FFFFFF), 0x00180918 },
  { 0xEA000940, (UINT32)~(0x00FFFFFF), 0x00180918 },
  { 0xEA000B40, (UINT32)~(0x00FFFFFF), 0x00180918 },
  { 0xEA002544, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002744, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA000944, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA000B44, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002548, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002748, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA000948, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA000B48, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002550, (UINT32)~(0x3F000000), 0x02000000 },
  { 0xEA002750, (UINT32)~(0x3F000000), 0x02000000 },
  { 0xEA000950, (UINT32)~(0x3F000000), 0x02000000 },
  { 0xEA000B50, (UINT32)~(0x3F000000), 0x02000000 },
  { 0xEA002554, (UINT32)~(0x003F0000), 0x00020000 },
  { 0xEA002754, (UINT32)~(0x003F0000), 0x00020000 },
  { 0xEA000954, (UINT32)~(0x003F0000), 0x00020000 },
  { 0xEA000B54, (UINT32)~(0x003F0000), 0x00020000 },
  { 0xEA002410, (UINT32)~(0xFFFF0000), 0x0D510000 },
  { 0xEA002610, (UINT32)~(0xFFFF0000), 0x0D510000 },
  { 0xEA000810, (UINT32)~(0xFFFF0000), 0x0D510000 },
  { 0xEA000A10, (UINT32)~(0xFFFF0000), 0x0D510000 },
  { 0xEA002400, (UINT32)~(0xCF030000), 0xCF030000 },
  { 0xEA002600, (UINT32)~(0xCF030000), 0xCF030000 },
  { 0xEA000800, (UINT32)~(0xCF030000), 0xCF030000 },
  { 0xEA000A00, (UINT32)~(0xCF030000), 0xCF030000 },
  { 0xEA002408, (UINT32)~(0xFFFC6108), 0xEA6C6108 },
  { 0xEA002608, (UINT32)~(0xFFFC6108), 0xEA6C6108 },
  { 0xEA000808, (UINT32)~(0xFFFC6108), 0xEA6C6108 },
  { 0xEA000A08, (UINT32)~(0xFFFC6108), 0xEA6C6108 },
  { 0xEA002418, (UINT32)~(0xFFFF0300), 0x38250100 },
  { 0xEA002618, (UINT32)~(0xFFFF0300), 0x38250100 },
  { 0xEA000818, (UINT32)~(0xFFFF0300), 0x38250100 },
  { 0xEA000A18, (UINT32)~(0xFFFF0300), 0x38250100 },
  { 0xEA002428, (UINT32)~(0xFF1F0000), 0x580E0000 },
  { 0xEA002628, (UINT32)~(0xFF1F0000), 0x580E0000 },
  { 0xEA000828, (UINT32)~(0xFF1F0000), 0x580E0000 },
  { 0xEA000A28, (UINT32)~(0xFF1F0000), 0x580E0000 },
  { 0xEA002438, (UINT32)~(0x0000000F), 0x0000000D },
  { 0xEA002638, (UINT32)~(0x0000000F), 0x0000000D },
  { 0xEA000838, (UINT32)~(0x0000000F), 0x0000000D },
  { 0xEA000A38, (UINT32)~(0x0000000F), 0x0000000D },
  { 0xEA002440, (UINT32)~(0x1F000000), 0x01000000 },
  { 0xEA002640, (UINT32)~(0x1F000000), 0x01000000 },
  { 0xEA000840, (UINT32)~(0x1F000000), 0x01000000 },
  { 0xEA000A40, (UINT32)~(0x1F000000), 0x01000000 },
  { 0xEA00242C, (UINT32)~(0x00020000), 0x00020000 },
  { 0xEA00262C, (UINT32)~(0x00020000), 0x00020000 },
  { 0xEA00082C, (UINT32)~(0x00020000), 0x00020000 },
  { 0xEA000A2C, (UINT32)~(0x00020000), 0x00020000 },
  { 0xEA00241C, (UINT32)~(0x00007C00), 0x00002400 },
  { 0xEA00261C, (UINT32)~(0x00007C00), 0x00002400 },
  { 0xEA00081C, (UINT32)~(0x00007C00), 0x00002400 },
  { 0xEA000A1C, (UINT32)~(0x00007C00), 0x00002400 },
  { 0xEA002500, (UINT32)~(0x0000E03E), 0x00004008 },
  { 0xEA002700, (UINT32)~(0x0000E03E), 0x00004008 },
  { 0xEA000900, (UINT32)~(0x0000E03E), 0x00004008 },
  { 0xEA000B00, (UINT32)~(0x0000E03E), 0x00004008 },
  { 0xEA00257C, (UINT32)~(0x000F3F00), 0x00003F00 },
  { 0xEA00277C, (UINT32)~(0x000F3F00), 0x00003F00 },
  { 0xEA00097C, (UINT32)~(0x000F3F00), 0x00003F00 },
  { 0xEA000B7C, (UINT32)~(0x000F3F00), 0x00003F00 }
};

IOBP_MMIO_TABLE_STRUCT PchSataSharedHsioLptH_B0[] = {
  { 0xEA0020A4, (UINT32)~(0x0030FF00), 0x00308300 },
  { 0xEA0022A4, (UINT32)~(0x0030FF00), 0x00308300 },
  { 0xEA0020AC, (UINT32)~(0x00000030), 0x00000020 },
  { 0xEA0022AC, (UINT32)~(0x00000030), 0x00000020 },
  { 0xEA002088, (UINT32)~(0x0000FF00), 0x00008000 },
  { 0xEA002288, (UINT32)~(0x0000FF00), 0x00008000 },
  { 0xEA002094, (UINT32)~(0x80000000), 0x80000000 },
  { 0xEA002294, (UINT32)~(0x80000000), 0x80000000 },
  { 0xEA002140, (UINT32)~(0x00FFFFFF), 0x00180918 },
  { 0xEA002340, (UINT32)~(0x00FFFFFF), 0x00180918 },
  { 0xEA002144, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002344, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002148, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002348, (UINT32)~(0x00FFFFFF), 0x00140918 },
  { 0xEA002150, (UINT32)~(0x3F000000), 0x02000000 },
  { 0xEA002350, (UINT32)~(0x3F000000), 0x02000000 },
  { 0xEA002154, (UINT32)~(0x003F0000), 0x00020000 },
  { 0xEA002354, (UINT32)~(0x003F0000), 0x00020000 },
  { 0xEA002010, (UINT32)~(0xFFFF0000), 0x0D510000 },
  { 0xEA002210, (UINT32)~(0xFFFF0000), 0x0D510000 },
  { 0xEA002000, (UINT32)~(0xCF030000), 0xCF030000 },
  { 0xEA002200, (UINT32)~(0xCF030000), 0xCF030000 },
  { 0xEA002008, (UINT32)~(0xFFFC6108), 0xEA6C6108 },
  { 0xEA002208, (UINT32)~(0xFFFC6108), 0xEA6C6108 },
  { 0xEA002018, (UINT32)~(0xFFFF0300), 0x38250100 },
  { 0xEA002218, (UINT32)~(0xFFFF0300), 0x38250100 },
  { 0xEA002028, (UINT32)~(0xFF1F0000), 0x580E0000 },
  { 0xEA002228, (UINT32)~(0xFF1F0000), 0x580E0000 },
  { 0xEA002038, (UINT32)~(0x0000000F), 0x0000000D },
  { 0xEA002238, (UINT32)~(0x0000000F), 0x0000000D },
  { 0xEA002040, (UINT32)~(0x1F000000), 0x01000000 },
  { 0xEA002240, (UINT32)~(0x1F000000), 0x01000000 },
  { 0xEA00202C, (UINT32)~(0x00020700), 0x00020100 },
  { 0xEA00222C, (UINT32)~(0x00020700), 0x00020100 },
  { 0xEA00201C, (UINT32)~(0x00007C00), 0x00002400 },
  { 0xEA00221C, (UINT32)~(0x00007C00), 0x00002400 },
  { 0xEA002100, (UINT32)~(0x0000E03E), 0x00004008 },
  { 0xEA002300, (UINT32)~(0x0000E03E), 0x00004008 },
  { 0xEA00217C, (UINT32)~(0x000F3F00), 0x00003F00 },
  { 0xEA00237C, (UINT32)~(0x000F3F00), 0x00003F00 }
};

IOBP_MMIO_TABLE_STRUCT PchUsb3HsioLptH_B0[] = {
  { 0xE9003140, (UINT32)~(0x00FFFFFF), 0x00040998 },
  { 0xE9003340, (UINT32)~(0x00FFFFFF), 0x00040998 },
  { 0xE9001540, (UINT32)~(0x00FFFFFF), 0x00040998 },
  { 0xE9001740, (UINT32)~(0x00FFFFFF), 0x00040998 },
  { 0xE900316C, (UINT32)~(0x000000FF), 0x0000003F },
  { 0xE900336C, (UINT32)~(0x000000FF), 0x0000003F },
  { 0xE900156C, (UINT32)~(0x000000FF), 0x0000003F },
  { 0xE900176C, (UINT32)~(0x000000FF), 0x0000003F },
  { 0xE9003168, (UINT32)~(0x01000F3C), 0x00000A28 },
  { 0xE9003368, (UINT32)~(0x01000F3C), 0x00000A28 },
  { 0xE9001568, (UINT32)~(0x01000F3C), 0x00000A28 },
  { 0xE9001768, (UINT32)~(0x01000F3C), 0x00000A28 },
  { 0xE900314C, (UINT32)~(0x00FF0000), 0x00140000 },
  { 0xE900334C, (UINT32)~(0x00FF0000), 0x00140000 },
  { 0xE900154C, (UINT32)~(0x00FF0000), 0x00140000 },
  { 0xE900174C, (UINT32)~(0x00FF0000), 0x00140000 },
  { 0xE9003164, (UINT32)~(0x0000F000), 0x00005000 },
  { 0xE9003364, (UINT32)~(0x0000F000), 0x00005000 },
  { 0xE9001564, (UINT32)~(0x0000F000), 0x00005000 },
  { 0xE9001764, (UINT32)~(0x0000F000), 0x00005000 },
  { 0xE9003170, (UINT32)~(0x00000018), 0x00000000 },
  { 0xE9003370, (UINT32)~(0x00000018), 0x00000000 },
  { 0xE9001570, (UINT32)~(0x00000018), 0x00000000 },
  { 0xE9001770, (UINT32)~(0x00000018), 0x00000000 },
  { 0xE90031CC, (UINT32)~(0x00001407), 0x00001401 },
  { 0xE90033CC, (UINT32)~(0x00001407), 0x00001401 },
  { 0xE90015CC, (UINT32)~(0x00001407), 0x00001401 },
  { 0xE90017CC, (UINT32)~(0x00001407), 0x00001401 }
};

IOBP_MMIO_TABLE_STRUCT PchUsb3SharedHsioLptH_B0[] = {
  { 0xE9002D40, (UINT32)~(0x00FFFFFF), 0x00040998 },
  { 0xE9002F40, (UINT32)~(0x00FFFFFF), 0x00040998 },
  { 0xE9002D6C, (UINT32)~(0x000000FF), 0x0000003F },
  { 0xE9002F6C, (UINT32)~(0x000000FF), 0x0000003F },
  { 0xE9002D44, (UINT32)~(0x000000FF), 0x00000014 },
  { 0xE9002F44, (UINT32)~(0x000000FF), 0x00000014 },
  { 0xE9002D68, (UINT32)~(0x01000F3C), 0x00000A28 },
  { 0xE9002F68, (UINT32)~(0x01000F3C), 0x00000A28 },
  { 0xE9002D4C, (UINT32)~(0x00FF0000), 0x00140000 },
  { 0xE9002F4C, (UINT32)~(0x00FF0000), 0x00140000 },
  { 0xE9002D64, (UINT32)~(0x0000F000), 0x00005000 },
  { 0xE9002F64, (UINT32)~(0x0000F000), 0x00005000 },
  { 0xE9002D70, (UINT32)~(0x00000018), 0x00000000 },
  { 0xE9002F70, (UINT32)~(0x00000018), 0x00000000 },
  { 0xE9002DCC, (UINT32)~(0x00001407), 0x00001401 },
  { 0xE9002FCC, (UINT32)~(0x00001407), 0x00001401 },
  { 0xE9002C2C, (UINT32)~(0x00000700), 0x00000100 },
  { 0xE9002E2C, (UINT32)~(0x00000700), 0x00000100 }
};

IOBP_MMIO_TABLE_STRUCT PchGbeSharedHsioLptH_B0[] = {
  { 0xE9002E08, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002C08, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002A08, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002808, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002608, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002408, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002208, (UINT32)~(0xF0000100), 0xE0000100 },
  { 0xE9002008, (UINT32)~(0xF0000100), 0xE0000100 }
};

IOBP_MMIO_TABLE_STRUCT PchDmiHsioLptH_B0[] = {
  { 0xEB002090, (UINT32)~(0x0000FF00), 0x00005100 },
  { 0xEB002290, (UINT32)~(0x0000FF00), 0x00005100 },
  { 0xEB000490, (UINT32)~(0x0000FF00), 0x00005100 },
  { 0xEB000690, (UINT32)~(0x0000FF00), 0x00005100 }
};

IOBP_MMIO_TABLE_STRUCT PchSataHsioLptH_DT_B0[] = {
  { 0xEA002490, (UINT32)~(0x0000FFFF), 0x00003E67 },
  { 0xEA002690, (UINT32)~(0x0000FFFF), 0x00003E67 },
  { 0xEA000890, (UINT32)~(0x0000FFFF), 0x00003E67 },
  { 0xEA000A90, (UINT32)~(0x0000FFFF), 0x00003E67 },
  { 0xEA00248C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA00268C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA00088C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA000A8C, (UINT32)~(0x00FF0000), 0x00800000 }
};

IOBP_MMIO_TABLE_STRUCT PchSataSharedHsioLptH_DT_B0[] = {
  { 0xEA002090, (UINT32)~(0x0000FFFF), 0x00003E67 },
  { 0xEA002290, (UINT32)~(0x0000FFFF), 0x00003E67 },
  { 0xEA00208C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA00228C, (UINT32)~(0x00FF0000), 0x00800000 }
};

IOBP_MMIO_TABLE_STRUCT PchSataHsioLptH_MB_B0[] = {
  { 0xEA002490, (UINT32)~(0x0000FFFF), 0x00004C5A },
  { 0xEA002690, (UINT32)~(0x0000FFFF), 0x00004C5A },
  { 0xEA000890, (UINT32)~(0x0000FFFF), 0x00004C5A },
  { 0xEA000A90, (UINT32)~(0x0000FFFF), 0x00004C5A },
  { 0xEA00248C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA00268C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA00088C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA000A8C, (UINT32)~(0x00FF0000), 0x00800000 }
};

IOBP_MMIO_TABLE_STRUCT PchSataSharedHsioLptH_MB_B0[] = {
  { 0xEA002090, (UINT32)~(0x0000FFFF), 0x00004C5A },
  { 0xEA002290, (UINT32)~(0x0000FFFF), 0x00004C5A },
  { 0xEA00208C, (UINT32)~(0x00FF0000), 0x00800000 },
  { 0xEA00228C, (UINT32)~(0x00FF0000), 0x00800000 }
};

#endif // TRAD_FLAG
