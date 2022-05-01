//
//  NavigationController.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Type erased version of the ``NavigationController``. Check that for more
 * information.
 */
public protocol _NavigationController: _ViewController {
  
  var rootViewController : _ViewController { get }
  
}

public extension _NavigationController {
  // This is the actual implementation the local VC's `show` hooks into.
  
  @inlinable
  func show<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
         where VC: ViewController, OwnerVC: _ViewController
  {
    owner.present(viewController, mode: .navigation)
  }
  @inlinable
  func showDetail<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
         where VC: ViewController, OwnerVC: _ViewController
  {
    show(viewController, in: owner)
  }
}

internal extension _NavigationController {
  
  func forEach(yield: ( _ViewController ) -> Bool) {
    guard yield(rootViewController) else { return }
    
    var presentation = rootViewController.activePresentation(for: .navigation)
    while let activePresentation = presentation {
      // Nested NavigationController. That will own the subsequent
      // presentations.
      if activePresentation.viewController is _NavigationController {
        break
      }
      guard activePresentation.mode == .navigation ||
            activePresentation.mode == .pushLink else { break }
      
      guard yield(activePresentation.viewController) else { break }
      presentation =
        activePresentation.viewController.activePresentation(for: .navigation)
    }
  }
  func forEach(yield : ( _ViewController ) -> Void) {
    forEach { _ in true }
  }
}

public extension _NavigationController {
  
  // MARK: - Accessors
  
  /**
   * The ``ViewController`` on top of the navigation stack, i.e. the "root".
   */
  @inlinable
  var topViewController: _ViewController { rootViewController }
  
  /**
   * The ``ViewController``s currently on the navigation stack of this
   * particular ``navigationController``.
   *
   * Careful: The ``NavigationController`` doesn't emit a change notification
   *          if any child view controllers change. (TBD)
   */
  var viewControllers : [ _ViewController ] {
    // Note: No setter until programmatic navigation actually works in
    //       SwiftUI ...
    
    get {
      var children = [ _ViewController ]()
      forEach { children.append($0) }
      return children
    }
  }

  /**
   * The ``ViewController``s a the bottom of the stack of the particular
   * ``navigationController``.
   *
   * Careful: The ``NavigationController`` doesn't emit a change notification
   *          if any child view controllers change. (TBD)
   */
  var visibleViewController : _ViewController {
    var cursor : _ViewController = rootViewController
    forEach { cursor = $0 }
    return cursor
  }
}


/**
 * A simple wrapper around SwiftUI's `NavigationView`.
 *
 * The primary purpose of this class is to tell the ``ViewController`` stack,
 * that a `NavigationView` is in place. So that `show` methods automatically
 * present in the `NavigationView` (instead of showing a sheet, etc).
 *
 * Example:
 * ```swift
 * struct ContentView: View { // the "scene view"
 *
 *   var body: some View {
 *     MainViewController(NavigationController(rootViewController: HomePage()))
 *   }
 * }
 * ```
 * 
 * Note that this works quite differently to a `UINavigationController`.
 * I.e. the controller does not really "own" the activation stack. Rather, the
 * ``ViewController``'s themselves define the activation trail.
 *
 * 2022-04-25: Note that programmatic navigation in SwiftUI is still a mess,
 *             so you can't reliably "deeplink".
 *             I.e. no `popToRootViewController`
 */
open class NavigationController<RootVC>: ViewController, _NavigationController
             where RootVC: ViewController
{
  
  // TODO: "show" instead of present

  public let _rootViewController : RootVC
  
  public var rootViewController : _ViewController { _rootViewController }
  
  public enum NavigationViewStyle: Equatable {
    case automatic
    
    @available(iOS 13.0, tvOS 13.0, watchOS 7.0, *)
    @available(macOS, unavailable)
    case stack
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    case columns
  }
  @Published public var navigationViewStyle = NavigationViewStyle.automatic
  
  public init(rootViewController: RootVC) {
    self._rootViewController = rootViewController
    markAsPresentingViewController()
  }
  
  private func markAsPresentingViewController() {
    rootViewController.presentingViewController = self
    activePresentations.append(ViewControllerPresentation(
      viewController: _rootViewController,
      mode: .custom // not .navigation, that would activate the bg link!
    ))
  }
  
  // MARK: - Description
  
  public func appendAttributes(to description: inout String) {
    defaultAppendAttributes(to: &description)
    description += " \(rootViewController)"
  }
  
  
  // MARK: - View
  
  private var _view: some View  {
    NavigationView {
      _rootViewController.view
        .controlled(by: _rootViewController)
        .navigationTitle(_rootViewController.navigationTitle)
    }
  }
  public var view: some View  {
    switch navigationViewStyle {
      case .automatic :
        _view
      case .stack     :
        #if os(macOS)
          _view
        #else
          _view.navigationViewStyle(.stack)
        #endif
      case .columns   :
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
          _view.navigationViewStyle(.columns)
        }
        else {
          _view
        }
      }
  }
}

public extension AnyViewController {

  @inlinable // Note: not a protocol requirement, i.e. dynamic!
  var navigationController : _NavigationController? {
    viewController.navigationController
  }
}

public extension _ViewController {
  
  /**
   * Return the ``NavigationController`` presenting this controller.
   *
   * Note: If the controller is a ``NavigationController`` itself, this does NOT
   *       return self. It still looks for the closest presenting controller.
   */
  var navigationController : _NavigationController? {
    /// Is this VC itself being presented?
    if let presentingVC = presentingViewController { // yes
      if let nvc = presentingVC as? _NavigationController { return nvc }
      return presentingVC.navigationController
    }
    return parent?.navigationController
  }
}
