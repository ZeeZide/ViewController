//
//  MainViewController.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * This allocates the state for, and assigns, a scene view controller,
 * i.e. one which starts a new VC hierarchy.
 * Usually only one root VC is used per scene.
 *
 * Checkout the ``View/main`` modifier for the more general solution.
 *
 * E.g. this could be used in the `ContentView` of an app like this:
 * ```swift
 * struct ContentView: View {
 *
 *   var body: some View {
 *     MainViewController(HomePage())
 *   }
 * }
 * ```
 */
public struct MainViewController<VC>: View where VC: ViewController {

  @StateObject private var viewController : VC
  
  public init(_ viewController: @escaping @autoclosure () -> VC) {
    self._viewController = StateObject(wrappedValue: viewController())
  }

  /**
   * Helper to avoid using ``presentInNavigation`` with a ``ViewController``
   * that doesn't have a proper ``ContentView``.
   */
  @available(*, unavailable,
             message: "The ViewController needs a proper `ContentView`")
  public init(_ viewController: @escaping @autoclosure () -> VC)
           where VC.ContentView == DefaultViewControllerView
  {
    assertionFailure("Incorrect use of ViewController")
    self._viewController = StateObject(wrappedValue: viewController())
  }

  public var body: some View {
    viewController
      .controlledContentView
  }
}
