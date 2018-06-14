/*++
  This file contains 'Framework Code' and is licensed as such   
  under the terms of your license agreement with Intel or your  
  vendor.  This file may not be modified, except as allowed by  
  additional terms of your license agreement.                   
--*/
/*++

Copyright (c)  1999 - 2002 Intel Corporation. All rights reserved
This software and associated documentation (if any) is furnished
under a license and may only be used or copied in accordance
with the terms of the license. Except as permitted by such
license, no part of this software or documentation may be
reproduced, stored in a retrieval system, or transmitted in any
form or by any means without the express written consent of
Intel Corporation.


Module Name:

  FaultTolerantWrite.c

Abstract:

  Fault Tolerant Write protocol as defined in the EFI 2.0 Falut Tolerant Write
  specification.

  This boot service only protocol provides fault tolerant write capability for 
  block devices.  The protocol provides for non-volatile intermediate storage 
  of the data and private information a caller would need to recover from a
  critical fault, such as power failure.   

--*/

#include "Tiano.h"
#include EFI_PROTOCOL_DEFINITION (FaultTolerantWrite)

EFI_GUID  gEfiFaultTolerantWriteProtocolGuid = EFI_FAULT_TOLERANT_WRITE_PROTOCOL_GUID;

EFI_GUID_STRING(&gEfiFaultTolerantWriteProtocolGuid, "FaultTolerantWrite Protocol", "Fault Tolerant Write protocol");
