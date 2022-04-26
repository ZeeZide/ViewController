//
//  DebugMode.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public enum ViewControllerDebugMode: Equatable {
  case none
  case overlay
}

public extension EnvironmentValues {
  
  @usableFromInline
  internal struct DebugModeKey: EnvironmentKey {
    #if DEBUG
      @usableFromInline
      static let defaultValue = ViewControllerDebugMode.overlay
    #else
      @usableFromInline
      static let defaultValue = ViewControllerDebugMode.none
    #endif
  }

  @inlinable
  var viewControllerDebugMode : ViewControllerDebugMode {
    set { self[DebugModeKey.self] = newValue }
    get { self[DebugModeKey.self] }
  }
}
