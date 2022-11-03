#!/usr/bin/swift

import Cocoa
import RegexBuilder

if #available(macOS 13.0, *) {
  enum TerminalCommand {
    static func run(_ command: String) throws -> String {
      let process = Process()
      let pipe = Pipe()

      process.standardOutput = pipe
      process.standardError = pipe
      process.arguments = ["-c", command]
      process.executableURL = URL(fileURLWithPath: "/bin/zsh")
      process.standardInput = nil

      try process.run()

      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: .utf8)!

      return output
    }
  }

  let currentSetting = Reference(Int.self)
  guard let stageManagerValue = try TerminalCommand
    .run("defaults read com.apple.WindowManager")
    .firstMatch(of: Regex {
      "AutoHide = "
      TryCapture(as: currentSetting) {
        OneOrMore(.digit)
      } transform: { match in
        Int(match)
      }
    }) else {
    fatalError("Unable to find AutoHide entry.")
  }

  let newStageManagerValue: Int
  if stageManagerValue[currentSetting] == 1 {
    newStageManagerValue = 0
  } else {
    newStageManagerValue = 1
  }

  let dockValue = try TerminalCommand
    .run("defaults read com.apple.Dock autohide")

  let toggleScript: String = dockValue == "1"
  ? "tell dock preferences to set autohide to true"
  : "tell dock preferences to set autohide to not autohide"

  let source = """
tell application "System Events"
    \(toggleScript)
end tell
"""

  let appleScript = NSAppleScript(source: source)
  var errorInfo: NSDictionary?

  appleScript?.executeAndReturnError(&errorInfo)

  _ = try TerminalCommand
    .run("defaults write com.apple.WindowManager AutoHide -int \(newStageManagerValue)")
}
