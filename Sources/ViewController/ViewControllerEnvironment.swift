//
//  ViewControllerPresentationModifier.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension EnvironmentValues {
  
  @usableFromInline
  internal struct ViewControllerKey: EnvironmentKey {
    public static let defaultValue : _ViewController? = nil
  }

  /**
   * Allows access to the ``ViewController``, w/o having the View refreshed if
   * the VC changes.
   *
   * Can be used like this:
   * ```swift
   * struct ContentView: View {
   *   @Environment(\.viewController) private var viewController
   *   var body: some View {
   *     Text(verbatim: "VC: \(viewController)")
   *   }
   * }
   * ```
   */
  @inlinable
  var viewController : _ViewController? {
    set { self[ViewControllerKey.self] = newValue }
    get { self[ViewControllerKey.self] }
  }
}

public extension View {

  /**
   * `.controlled(vc)` pushes the ``ViewController`` as an environment object,
   * both under its concrete type, and as the generic ``ViewController``.
   *
   * It also pushes the VC into the `viewController` environment key, which
   * allows access w/o having a View refresh on VC changes (kinda like an
   * `UnobservedEnvironmentObject`).
   *
   * This also sets up the sheet/programmatic `NavigationLink` for automatic
   * presentation.
   *
   * Externally this modifier is usually only used at the very top of the VC
   * stack, i.e. for the "SceneController":
   * ```swift
   * struct ContentView: View {
   *
   *   @StateObject private var viewController : WidgetViewVC
   *
   *   var body: some View {
   *     NavigationView {
   *       WidgetViewVC.ContentView()
   *         .controlled(by: viewController)
   *     }
   *   }
   * }
   * ```
   *
   * - Parameters:
   *   - viewController: The (instantiated) view controller object to apply to
   *                     View.
   */
  func controlled<VC: ViewController>(by viewController: VC)
       -> some SwiftUI.View
  {
    // Note: Also used internally during presentation.
    self
      .modifier(AutoPresentationViewModifier(viewController: viewController))
      .modifier(ControlledViewModifier(viewController: viewController))
  }
}

// Push the VC into the environment by three means:
// - as an EnvironmentObject using its concrete class
// - type-erased, as an ``AnyViewController`` EnvironmentObject
// - as a plain `viewController` environment key (w/o state observation)
fileprivate struct ControlledViewModifier<VC>: ViewModifier
                     where VC: ViewController
{
  
  let viewController : VC

  func body(content: Content) -> some View {
    content
      .environmentObject(viewController)
      .environmentObject(AnyViewController(viewController))
      .environment(\.viewController, viewController)
  }
}
