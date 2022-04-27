//
//  PushLink.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Push a new view controller and navigate to it within a `NavigationView`
 * (using a `NavigationLink`).
 * 
 * Note: Unlike an explicit `Button` calling `present` or `show`,
 *       a `PushLink` caches the target controller while active.
 *       I.e. pressing the same `PushLink` twice, will not result in a new
 *       instantiation.
 *
 * Content View Example:
 * ```swift
 * class HomePage: ViewController {
 *   var view: some View {
 *     PushLink("Preferences…", to: PreferencesPage())
 *   }
 * }
 * ```
 *
 * Explicit View Example:
 * ```swift
 * class HomePage: ViewController {
 *   var view: some View {
 *     PushLink(to: PreferencesPage(), using: Text("Prefs!") {
 *       Text("Preferences…")
 *     }
 *   }
 * }
 * ```
 *
 * A workaround until I found a way to make the `NavigationLink` init extension
 * working.
 */
public struct PushLink<VC, CV, Label>: View
         where VC: ViewController, CV: View, Label: View
{
  // TBD: Call this `PushSegue`?
  // This works, but not as nice as being able to use NavLink directly.

  @EnvironmentObject private var parentViewController : AnyViewController
  @State             private var childViewController  : _ViewController?
  private let childViewControllerFactory : () -> VC
  private let contentView                : CV
  private let label                      : Label
  
  private let mode = ViewControllerPresentationMode.pushLink
  
  
  // MARK: - Public Initializers

  /**
   * Create a ``PushLink`` that is using an explicit `View` as the destination.
   *
   * Example:
   * ```
   * PushLink(to: SettingsPage(), using: MySettingsView()) {
   *   Text("Go to settings…")
   * }
   * ```
   */
  public init(to  viewController : @autoclosure @escaping () -> VC,
              using  contentView : CV,
              @ViewBuilder label : () -> Label)
  {
    self.childViewControllerFactory = viewController
    self.contentView                = contentView
    self.label                      = label()
  }

  
  // MARK: - Implementation

  private var isActive : Bool {
    // The thing to keep in mind here is that the `childViewController` is NOT
    // the truth. The truth is the presentation state in the
    // `parentViewController`.
    guard let activeVC = childViewController else {
      logger.debug("PushLink[isActive]: no CVC is set…")
      return false
    }
    guard let presentation =
                parentViewController.activePresentation(for: activeVC) else
    {
      // OK, this is FINE. It happens because when clicking a different NavLink
      // the _new_ position is set to "showing" before the old one is being
      // dismissed.
      // Note: Do not update state in an accessor!
      logger.debug(
        "PushLink[isActive]: No presentation: \(activeVC.description), off.")
      return false
    }
    
    assert(presentation.viewController === activeVC)
    logger.debug("PushLink[isActive]: active: \(activeVC.description)")
    return presentation.viewController === activeVC
  }
  
  private func presentIfNecessary() {
    if let activeVC = childViewController { // we are already active
      logger.debug(
        "PushLink[present]: VC is already active: \(activeVC.description)")
      assert(isActive) // checks the parent as well
      return
    }
    
    // Not yet active
    let activeVC = childViewControllerFactory()
    logger.debug("PushLink[present]: VC \(activeVC) \(mode)")
    childViewController = activeVC
    parentViewController.present(activeVC, mode: mode)
  }
  
  private func dismissIfNecessary() {
    // The thing to keep in mind here is that the `childViewController` is NOT
    // the truth. The truth is the presentation state in the
    // `parentViewController`.
    guard let activeVC = childViewController else {
      logger.debug("PushLink[dismiss]: no VC is active: \(parentViewController)")
      return
    }

    defer { childViewController = nil }

    // OK, we have the local VC state, but is the VC still active in the parent
    // ViewController?
    guard let _ = parentViewController.activePresentation(for: activeVC) else {
      // OK, this is FINE. It happens because when clicking a different NavLink
      // the _new_ position is set to "showing" before the old one is being
      // dismissed.
      // This is called during a View update. We should not update state in
      // here, but only in the follow up, which will call our Binding w/ a
      // isActive=false (but only _after_ setting the new item to true)
      logger.debug(
        "PushLink[dismiss]: No presentation: \(activeVC.description), off.")
      
      if activeVC.presentingViewController != nil {
        logger.error(
          "PushLink[dismiss]: \(activeVC.description) wasn't dismissed?")
        assert(activeVC.presentingViewController == nil,
               "The cache VC should have been dismissed!")
        activeVC.dismiss()
      }
      
      return
    }

    logger.debug("PushLink[dismiss]: \(activeVC.description)")
    activeVC.dismiss()
    logger.debug("PushLink[dismiss]: done: \(activeVC.description)")
  }
  
  private var isActiveBinding: Binding<Bool> {
    Binding(
      get: {
        isActive
      },
      set: { isActive in
        if isActive { presentIfNecessary() }
        else { dismissIfNecessary() }
      }
    )
  }
  
  @ViewBuilder private var destination: some View {
    if let presentedVC = parentViewController
             .presentedViewController(of: VC.self, mode: mode)
    {
      contentView
        .controlled(by: presentedVC)
        .environment(\.viewControllerPresentationMode, .navigation)
        .navigationTitle(presentedVC.navigationTitle)
    }
    else {
      SwiftUI.Label("Error: Missing/wrong presented VC",
                    systemImage: "exclamationmark.triangle")
    }
  }
  
  public var body: some View {
    NavigationLink(
      isActive    : isActiveBinding,
      destination : { destination },
      label       : { label }
    )
  }
}


// MARK: - Convenience Initializers

extension PushLink {

  /**
   * Create a ``PushLink`` that is using the ``ViewController/view``
   * as the destination.
   *
   * Example:
   * ```
   * PushLink(to: SettingsPage()) {
   *   Text("Go to settings…")
   * }
   * ```
   */
  @inlinable
  public init(to  viewController : @autoclosure @escaping () -> VC,
              @ViewBuilder label : () -> Label)
    where VC: ViewController, CV == RenderContentView<VC>
  {
    assert(VC.ContentView.self != DefaultViewControllerView.self,
           "Attempt to use ContentView based Push w/ VC w/o ContentView")
    self.init(to: viewController(), using: RenderContentView<VC>()) { label() }
  }

  /**
   * Create a ``PushLink`` that is using the ``ViewController/view``
   * as the destination.
   *
   * Example:
   * ```
   * PushLink("Go to settings…", to: SettingsPage())
   * ```
   */
  @inlinable
  public init<S>(_ title: S, to viewController: @autoclosure @escaping () -> VC)
    where VC: ViewController, CV == RenderContentView<VC>,
          Label == Text, S: StringProtocol
  {
    assert(VC.ContentView.self != DefaultViewControllerView.self,
           "Attempt to use ContentView based Push w/ VC w/o ContentView")
    self.init(to: viewController(), using: RenderContentView<VC>()) {
      Text(title)
    }
  }

  /**
   * Create a ``PushLink`` that is using the ``ViewController/ContentView``
   * as the destination.
   *
   * Example:
   * ```
   * PushLink("Go to settings…", to: SettingsPage())
   * ```
   */
  @inlinable
  public init(_ titleKey: LocalizedStringKey,
              to viewController: @autoclosure @escaping () -> VC)
    where VC: ViewController, CV == RenderContentView<VC>, Label == Text
  {
    assert(VC.ContentView.self != DefaultViewControllerView.self,
           "Attempt to use ContentView based Push w/ VC w/o ContentView")
    self.init(to: viewController(), using: RenderContentView<VC>()) {
      Text(titleKey)
    }
  }

}


// MARK: - Unavailable Initializers

extension PushLink {
  
  /**
   * Helper to avoid using ``PushLink`` on a ``ViewController`` w/o a proper
   * ``ContentView``.
   */
  @available(*, unavailable,
             message: "The ViewController needs a proper `ContentView`")
  public init(to  viewController : @autoclosure @escaping () -> VC,
              @ViewBuilder label : () -> Label)
    where VC: ViewController, CV == RenderContentView<VC>,
          VC.ContentView == DefaultViewControllerView
  {
    assert(VC.ContentView.self != DefaultViewControllerView.self,
           "Attempt to use ContentView based Push w/ VC w/o ContentView")
    self.init(to: viewController(), using: RenderContentView<VC>()) { label() }
  }
  
  /**
   * Helper to avoid using ``PushLink`` on a ``ViewController`` w/o a proper
   * ``ContentView``.
   */
  @available(*, unavailable,
             message: "The ViewController needs a proper `ContentView`")
  public init<S>(_ title: S, to viewController: @autoclosure @escaping () -> VC)
    where VC: ViewController, CV == RenderContentView<VC>,
          Label == Text, S: StringProtocol,
          VC.ContentView == DefaultViewControllerView
  {
    assert(VC.ContentView.self != DefaultViewControllerView.self,
           "Attempt to use ContentView based Push w/ VC w/o ContentView")
    self.init(title, to: viewController())
  }

  /**
   * Helper to avoid using ``PushLink`` on a ``ViewController`` w/o a proper
   * ``ContentView``.
   */
  @available(*, unavailable,
             message: "The ViewController needs a proper `ContentView`")
  public init(_ titleKey: LocalizedStringKey,
              to viewController: @autoclosure @escaping () -> VC)
    where VC: ViewController, CV == RenderContentView<VC>, Label == Text,
          VC.ContentView == DefaultViewControllerView
  {
    assert(VC.ContentView.self != DefaultViewControllerView.self,
           "Attempt to use ContentView based Push w/ VC w/o ContentView")
    self.init(to: viewController(), using: RenderContentView<VC>()) {
      Text(titleKey)
    }
  }
}
