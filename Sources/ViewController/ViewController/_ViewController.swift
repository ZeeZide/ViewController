//
//  _ViewController.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import Combine

/**
 * The base protocol which can be used as an existential.
 *
 * Associated types added by ``ViewController``:
 * - ObjectWillChangePublisher
 * - ContentView
 * - RepresentedValue
 */
public protocol _ViewController: AnyObject, CustomStringConvertible {
  // Even just `ObservableObject` is a PAT.
  
  typealias ObjectWillChangePublisher = ObservableObjectPublisher
  
  typealias PresentationMode = ViewControllerPresentationMode

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


  // MARK: - Better Description
  
  /**
   * Override in subclasses to add own properties to the VC description.
   */
  func appendAttributes(to description: inout String)


  // MARK: - Type Erasure

  /**
   * Returns the type erased ``ContentView`` of the ``ViewController``.
   */
  var anyContentView : AnyView { get }

  /**
   * Returns the type erased ``ContentView`` of the ``ViewController``,
   * with the ``ViewController`` being applied as the ``controlled(by:)``
   * View.
   */
  var anyControlledContentView : AnyView { get }

  /**
   * Returns the type erased represented object of the ``ViewController``.
   */
  var anyRepresentedObject : Any?    { set get }
}
