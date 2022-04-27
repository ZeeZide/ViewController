//
//  ViewController.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import Combine

/**
 * A ``ViewController``.
 *
 * TODO: lotsa more documentation
 *
 * In WebObjects those would be called `WOComponent`s and are accessible
 * using the Environment (`WOContext` in WebObjects).
 * I.e. the SwiftUI environment always tracks the "active" VC.
 *
 * The lifecycle events also do not reflect whether the VC is "really" on
 * screen, just whether it has been presented.
 *
 * ### Custom Presentation
 *
 * There are two parts to presenting a ViewController in a custom way:
 * - Call `present` on the active viewController with the instance of the new,
 *   child ViewController. The active VC can be accessed using
 *   `@EnvironmentObject private var viewController : ViewController`
 *   (or the specific VC subclass)
 * - To choose the presentation style, attach it to the View, for example:
 *   `.presentInNavigation(ChildVC.self) { ChildVC.ContentView() }`
 */
public protocol ViewController: _ViewController, ObservableObject, Identifiable
{
  
  // Note: We can't use an own View w/o crashing swiftc 5.6? Or is the issue
  //       limited to a single module?
  typealias DefaultViewControllerView = EmptyView
  
  /**
   * The primary View associated with the ViewController.
   *
   * There doesn't have to be just one View associated with the ViewController,
   * the ViewController itself can be decoupled from a specific `ContentView`.
   * E.g. there could be a different main View for macOS and for iOS.
   *
   * But having a single associated `ContentView` allows for more convenient
   * APIs for that common case.
   *
   * Implicit View via `view` accessor:
   * ```swift
   * class Contacts: ViewController {
   *
   *   var view: some View {
   *     Text("The Contacts!")
   *   }
   * }
   * ```
   *
   * Implicit View, explicit class:
   * ```swift
   * class Contacts: ViewController {
   *
   *   struct ContentView: View {
   *
   *     @EnvironmentObject var viewController: Contacts
   *
   *     var body: some View {
   *        Text("The Contacts!")
   *     }
   *   }
   * }
   * ```
   */
  associatedtype ContentView : SwiftUI.View = DefaultViewControllerView
  
  /**
   * Dirty trick to let the user avoid the need to explicitly specify the
   * `ViewControllerView` when declaring Views within the scope of a
   * ViewController.
   *
   * Example:
   * ```swift
   * class Contacts: ViewController {
   *
   *   struct ContentView: View { // <== this is really a ViewControllerView
   *     ...
   *   }
   * }
   * ```
   */
  typealias View = ViewControllerView

  /**
   * Returns the ``ContentView`` associated with the ``ViewController``.
   *
   * One way to specify an associated ``View`` for the controller is by
   * overriding this property, for example:
   * ```swift
   * class Contacts: ViewController {
   *
   *   var view: some View {
   *     Text("The Contacts!")
   *   }
   * }
   * ```
   *
   * Another way is to use a ``ViewControllerView`` (just a plain `View` w/
   * an `init` method w/o arguments, used to instantiate the `View`):
   * ```swift
   * class Contacts: ViewController {
   *
   *   struct ContentView: View {
   *
   *     @EnvironmentObject var viewController: Contacts
   *
   *     var body: some View {
   *        Text("The Contacts!")
   *     }
   *   }
   * }
   * ```
   */
  @ViewBuilder var view : ContentView { get }
  
  
  // MARK: - Represented Object
  
  associatedtype RepresentedValue = Any

  /**
   * Get or set a value represented by the ViewController.
   *
   * Quite often VCs are used to deal with one primary model object.
   * This can be used to directly associated that w/ the View.
   *
   * The default implementation is going to subscribe and republish the
   * `willChange` notification if the ``RepresentedValue`` is an
   * `ObservableObject` itself.
   */
  var representedObject : RepresentedValue? { get set }


  // MARK: - Titles
  
  /**
   * Get or set a title associated with a ViewController.
   */
  var title : String? { set get }
  
  /**
   * Returns the ``title`` of the ``ViewController``,
   * but falls back to a default title in case that's not available.
   *
   * Suitable for use in `navigationTitle`, `navigationBarTitle` and similar
   * SwiftUI `View` modifiers.
   */
  var navigationTitle : String { get }

  
  // MARK: - Presentation
  
  /**
   * Defines the default style in which a ``ViewController`` wants to be
   * presented in.
   */
  var modalPresentationStyle   : ViewControllerPresentationMode { set get }

  /// An internal property to track the ViewController presentation.
  var activePresentations      : [ ViewControllerPresentation ] { set get }
  
  /**
   * If the ``ViewController`` is presenting another, this property returns
   * the presented ViewController.
   */
  var presentedViewController  : _ViewController? { get }
  
  /**
   * If the ``ViewController`` got presented by another, this property returns
   * the ViewController doing the presentation.
   */
  var presentingViewController : _ViewController? { set get }
  
  /**
   * This is called if the VC was added as the presented VC, but SwiftUI
   * still needs a tick to diff and actually display the related view.
   */
  func willAppear()
  
  /**
   * This is called if the VC was removed as a presented VC. SwiftUI will still
   * need a tick to diff and remove the related view.
   */
  func willDisappear()
  
  /**
   * Make the ``ViewController`` the currently presented ``ViewController`` for
   * the given mode.
   */
  func present<VC>(_ viewController: VC, mode: PresentationMode)
         where VC: ViewController
  /**
   * Make the ``ViewController`` the currently presented ``ViewController``,
   * in `.automatic` mode.
   */
  func present<VC: ViewController>(_ viewController: VC)
  /**
   * Present a ``ViewController`` that doesn't have a
   * ``ViewController/ContentView`` assigned.
   */
  func present<VC: ViewController>(_ viewController: VC)
         where VC.ContentView == DefaultViewControllerView

  func show<VC: ViewController>(_ viewController: VC)
  func show<VC: ViewController>(_ viewController: VC)
         where VC.ContentView == DefaultViewControllerView
  
  func showDetail<VC: ViewController>(_ viewController: VC)
  func showDetail<VC: ViewController>(_ viewController: VC)
         where VC.ContentView == DefaultViewControllerView

  /// Internal method which allows presenting view controllers the actual
  /// presentation further down in the stack.
  func show<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
         where VC: ViewController, OwnerVC: _ViewController
  /// Internal method which allows presenting view controllers the actual
  /// presentation further down in the stack.
  func showDetail<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
         where VC: ViewController, OwnerVC: _ViewController

  /**
   * Remove the ViewController from being presented in its presenting
   * ViewController.
   *
   * Will call `willDisappear` (only) if it actually was presented by the
   * parent.
   */
  func dismiss()
  
  
  // MARK: - Hierarchy
  
  /**
   * The array of contained view controllers (children).
   *
   * Use ``addChild`` to add children to this array and use ``removeFromParent``
   * to remove a child from its parent.
   *
   * Not to be confused w/ ``presentedViewControllers``.
   */
  var children : [ _ViewController ] { set get }
  /**
   * The parent of a contained ``ViewController`` (if it is actually contained).
   *
   * Use ``addChild`` to add children to a parent and use ``removeFromParent``
   * to remove a child from its parent.
   *
   * Not to be confused w/ ``presentingViewController``.
   */
  var parent : _ViewController?      { set get }
  
  /**
   * This is called once the ViewController will be added or removed as a child.
   */
  func willMove(toParent parent: _ViewController?)
  
  /**
   * This is called once the ViewController was added or removed as a child.
   */
  func didMove(toParent parent: _ViewController?)

  /**
   * Add the specified ``ViewController`` as a child ("contained")
   * ViewController.
   *
   * This will add the `viewController` to the ``children`` array and set its
   * ``parent`` property.
   */
  func addChild<VC: ViewController>(_ viewController: VC)
  
  /**
   * Remove the ``ViewController`` from its parent.
   */
  func removeFromParent()
}
