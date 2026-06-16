// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import TTS

func yesConfirmation() throws {
   print("Do you want to proceed? [y/\("N".styles(.bold))]")
   guard ["Y", "y", "Yes", "yes"].contains(readLine()) else {
      throw ExitCode.success
   }
}
