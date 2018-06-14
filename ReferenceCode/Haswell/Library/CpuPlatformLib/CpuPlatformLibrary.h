/** @file
  Header file for Cpu Platform Lib implementation.

@copyright
  Copyright (c) 2012 Intel Corporation. All rights reserved
  This software and associated documentation (if any) is furnished
  under a license and may only be used or copied in accordance
  with the terms of the license. Except as permitted by such
  license, no part of this software or documentation may be
  reproduced, stored in a retrieval system, or transmitted in any
  form or by any means without the express written consent of
  Intel Corporation.

  This file contains a 'Sample Driver' and is licensed as such
  under the terms of your license agreement with Intel or your
  vendor.  This file may be modified by the user, subject to
  the additional terms of the license agreement
**/
#ifndef _CPU_PLATFORM_LIBRARY_IMPLEMENTATION_H_
#define _CPU_PLATFORM_LIBRARY_IMPLEMENTATION_H_

#if !defined(EDK_RELEASE_VERSION) || (EDK_RELEASE_VERSION < 0x00020000)
#include "EdkIIGlueBase.h"
#include "EdkIIGluePeim.h"
#include "CpuAccess.h"
#include "CpuPlatformLib.h"
#include "PchAccess.h"
#include "PchPlatformLib.h"
#endif

#endif
