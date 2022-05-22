//
//  Logger.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import os
import class Foundation.ProcessInfo

// Print Log Helper, since we apparently can't set the log level of os_log 🤦‍♀️

#if DEBUG && true

@usableFromInline
struct PrintLogger {
  
  static let logLevel : OSLogType = {
    let env = ProcessInfo.processInfo.environment
    switch (env["VIEWCONTROLLER_LOGLEVEL"] ?? env["LOGLEVEL"])?.lowercased() {
      case "error" : return .error
      case "debug" : return .debug
      case "fault" : return .fault
      case "info"  : return .info
      default: return OSLogType.default
    }
  }()
  var logLevel : OSLogType { Self.logLevel }

  func log(_ level: OSLogType, _ prefix: String, _ message: () -> String) {
    guard level.rawValue >= self.logLevel.rawValue else { return }
    print(prefix + message())
  }
  
  @usableFromInline
  func debug(_ message: @autoclosure () -> String) {
    log(.debug, "", message)
  }
  @usableFromInline
  func warning(_ message: @autoclosure () -> String) {
    log(.error, "WARN: ", message)
  }
  @usableFromInline
  func error(_ message: @autoclosure () -> String) {
    log(.error, "ERROR: ", message)
  }
}

@usableFromInline
let logger = PrintLogger()

#else

@usableFromInline
let logger = Logger(
  subsystem : Bundle.main.bundleIdentifier ?? "Main",
  category  : "VC"
)
#endif
