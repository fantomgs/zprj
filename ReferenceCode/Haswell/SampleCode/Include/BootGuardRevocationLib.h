/** @file
  Header file for Boot Guard revocation notification.

@copyright
  Copyright (c) 2012 - 2013 Intel Corporation. All rights reserved
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
#ifndef _BOOT_GUARD_REVOCATION_LIB_H_
#define _BOOT_GUARD_REVOCATION_LIB_H_

#if !defined(EDK_RELEASE_VERSION) || (EDK_RELEASE_VERSION < 0x00020000)
#include "EdkIIGlueDxe.h"
#endif

/**
  Provide a hook for OEM to deal with Boot Guard revocation flow.
**/
VOID
EFIAPI
BootGuardOemRevocationHook (
  VOID
  );

#endif
