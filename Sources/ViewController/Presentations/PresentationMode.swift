//
//  PresentationMode.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * The active presentation mode for the ViewController. Can be accessed in the
 * environment using:
 * ```swift
 * public struct ContentView: View {
 *   @Environment(\.viewControllerPresentationMode) private var mode
 *
 *   var body: some View {
 *     if mode == .sheet {
 *       Text("I'm in a sheet!")
 *     }
 *     else {
 *       Text("I'm in a sheet, NOT!")
 *     }
 *   }
 * }
 * ```
 */
public enum ViewControllerPresentationMode: Hashable {
  // FIXME: Used in two different ways, for accessing the actual presentation,
  //        and for deciding what presentation to use.
  
  /**
   * The ``ViewController`` will decide on an appropriate presentation mode.
   */
  case automatic
  
  /**
   * The ``ViewController`` won't do the presentation automagically,
   * the user needs to handle it explicitly
   * (e.g. using the `.sheet` modifier or a programmatic `NavigationLink` with
   *  the `isActive` bound to the `presentedViewController`).
   */
  case custom
  
  /**
   * The presentation is done in a sheet that is handled automatically by the
   * framework.
   */
  case sheet
  
  /**
   * The presentation is done using a programmatic `NavigationLink` that is
   * handled automatically by the framework.
   */
  case navigation
  
  /**
   * The presentation is done using the ``PushLink``, an wrapped,
   * in-View `NavigationLink`.
   */
  case pushLink
  
  // TODO: popover
}

extension ViewControllerPresentationMode: CustomStringConvertible {
  
  public var description: String {
    switch self {
      case .automatic  : return "PM:auto"
      case .custom     : return "PM:custom"
      case .sheet      : return "PM:sheet"
      case .navigation : return "PM:nav"
      case .pushLink   : return "PM:push"
    }
  }
}

public extension ViewController {
  
  /**
   * The active presentation mode for the ViewController. Can be accessed in the
   * environment using:
   * ```swift
   * public struct ContentView: View {
   *   @Environment(\.viewControllerPresentationMode) private var mode
   * }
   * ```
   */
  typealias PresentationMode = ViewControllerPresentationMode
}

public extension EnvironmentValues {
  
  @usableFromInline
  internal struct ViewControllerPresentationModeKey: EnvironmentKey {
    public static let defaultValue = ViewController.PresentationMode.custom
  }

  /**
   * Access the means by which the current ``ViewController`` got presented,
   * i.e. `sheet` or `navigation`.
   *
   * This is set properly by either the `presentInSheet`, `presentInNavigation`
   * and the likes.
   *
   * This is sometimes useful to define how "inner" UI should look like.
   * Example:
   * ```swift
   * public struct ContentView: View {
   *   @EnvironmentObject private var viewController : ViewController
   *   @Environment(\.viewControllerPresentationMode) private var mode
   *
   *   var body: some View {
   *     Text("Hi!")
   *
   *     // show explicit dismiss button for ``NavigationView`` pushes only.
   *     if mode == .navigation {
   *       Button("Dismiss", action: viewController.dismiss)
   *     }
   *   }
   * }
   * ```
   */
  @inlinable
  var viewControllerPresentationMode : ViewController.PresentationMode {
    set { self[ViewControllerPresentationModeKey.self] = newValue }
    get { self[ViewControllerPresentationModeKey.self] }
  }
}
