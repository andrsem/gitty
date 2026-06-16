// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import Configurator
import Foundation
import SW40
import TTS

@main
struct Gitty: AsyncParsableCommand {
   @Flag(help: .Gitty.configPath)
   var configPath: Bool = false

   @Flag(help: .Gitty.regexReference)
   var regexReference = false


   func validate() throws {
      try Configurator.initializeConfigs()
      printingLogoInHelp()
      if configPath { throw CleanExit.message(Configurator.configDir.path()) }
      if regexReference { throw CleanExit.message(regexReferenceGuide) }
   }


   static let configuration = CommandConfiguration(
      commandName: "gitty",
      abstract: "Customizable status line tool for multiple Git repos",
      usage: """
         gitty <subcommand>
         gitty [--config-path] [--regex-reference]
         """,
      version: "1.0.0-preview-1",
      subcommands: subcommands,
      defaultSubcommand: StatusSub.self
   )


   private static let subcommands: [any ParsableCommand.Type] = [
      ListSub.self,
      StatusSub.self,
      RunSub.self,
   ]


   private func printingLogoInHelp() {
      let commands = Self.subcommands.flatMap {
         let long = $0._commandName
         let short = long.prefix(1) |> String.init
         return [long, short]
      }

      let args = CommandLine.arguments.dropFirst()
      let hasHelpFlag = args.contains("-h") || args.contains("--help")
      let notSubcommand = !args.contains(where: commands.contains)

      if hasHelpFlag && notSubcommand { print(Self.logo + "\n") }
   }


   // Manual resets display the logo without breaking in a terminal window at least 50 columns wide.
   static var logo: String {
      """

      \("                 ||      ||".fgM(220))\("".fgM(105))
      \("           ''".styles(.blink))    \("||      ||".fgM(214))
      \("   .|''|,  ||  ''||''  ''||''   ||  ||".fgM(208))
      \("   ||  ||  ||    ||      ||     `|..||".fgM(202))
      \("   `|..||  ||    `|..'   `|..'      ||".fgM(196))
      \("       ||                        ,  |'".fgM(196))
      \("    `..|'                         ''  ".fgM(196))

      """
      .styles(.bold)
      .reset()
   }
}



extension String {
   fileprivate func fgM(_ ext: Int) -> Self { fg(ext, reset: .manual) }
}
