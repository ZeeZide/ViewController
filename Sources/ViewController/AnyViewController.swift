//
//  AnyViewController.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import Combine
import SwiftUI

/**
 * A type erased version of a (statically typed) ``ViewController``.
 *
 * If possible type erasure should be avoided.
 *
 * When a ``ViewController`` is pushed into the environment, it is pushed
 * as an `@EnvironmentObject` of its concrete type, but also as an
 * ``AnyViewController``. This allows access of all common methods
 * (e.g. ``ViewController/dismiss``).
 *
 * Example access:
 * ```swift
 * struct TitleLabel: View {
 *
 *   @EnvironmentObject private var viewController : AnyViewController
 *
 *   var body: some View {
 *     Text(verbatim: viewController.title)
 *       .font(.title)
 *   }
 * }
 * ```
 */
public final class AnyViewController: ViewController {
  
  public   var id : ObjectIdentifier { ObjectIdentifier(viewController) }
    
  public   let viewController : _ViewController
  private  var subscription   : AnyCancellable?
  
  @usableFromInline
  internal let contentView    : () -> AnyView
  
  public init<VC>(_ viewController: VC) where VC: ViewController {
    assert(!(viewController is AnyViewController),
           "Attempt to nest an AnyVC into another \(viewController)")
    
    self.viewController = viewController
    self.contentView    = { AnyView(viewController.view) }
    
    subscription = viewController.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
  }
  
  /**
   * An initializer that avoids nesting `AnyViewController`s into themselves.
   */
  init(_ viewController: AnyViewController) {
    self.viewController = viewController.viewController
    self.contentView    = viewController.contentView
    
    // TBD: Can't unwrap this?
    subscription = viewController.objectWillChange.sink {
      [weak self] _ in
      self?.objectWillChange.send()
    }
  }


  // MARK: - All the any
  // Those are typed erased by the base protocol already (_ViewController).
  
  @inlinable
  @ViewBuilder public var view : AnyView { contentView() }
  
  @inlinable
  public var controlledContentView : AnyView { anyControlledContentView }
  @inlinable
  public var anyControlledContentView : AnyView {
    viewController.anyControlledContentView
  }

  
  // MARK: - Titles
  
  @inlinable
  public var title           : String? {
    set { viewController.title = newValue }
    get { viewController.title }
  }
  
  @inlinable
  public var navigationTitle : String { viewController.navigationTitle }
  
  
  // MARK: - Represented Object

  @inlinable
  public var representedObject : Any? {
    set { anyRepresentedObject = newValue }
    get { anyRepresentedObject }
  }
  @inlinable
  public var anyRepresentedObject : Any? {
    set { viewController.anyRepresentedObject = newValue }
    get { viewController.anyRepresentedObject }
  }


  // MARK: - Presentation

  @inlinable
  public var presentedViewController : _ViewController? {
    get { viewController.presentedViewController }
  }
  @inlinable
  public var activePresentations : [ ViewControllerPresentation ] {
    set { viewController.activePresentations = newValue }
    get { viewController.activePresentations }
  }
  @inlinable
  public var presentingViewController : _ViewController? {
    set { viewController.presentingViewController = newValue }
    get { viewController.presentingViewController }
  }
  
  @inlinable
  public func willAppear()    { viewController.willAppear() }
  @inlinable
  public func willDisappear() { viewController.willDisappear()  }

  @inlinable
  public func present<VC>(_ viewController: VC,
                          mode: ViewControllerPresentationMode)
                where VC: ViewController
  {
    self.viewController.present(viewController, mode: mode)
  }
  @inlinable
  public func present<VC: ViewController>(_ viewController: VC) {
    self.viewController.present(viewController)
  }
  @inlinable
  public func dismiss() { viewController.dismiss() } // TBD: really unwrap?

  
  @inlinable
  public func show<VC: ViewController>(_ viewController: VC) {
    self.viewController.show(viewController)
  }
  
  @inlinable
  public func showDetail<VC: ViewController>(_ viewController: VC){
    self.viewController.showDetail(viewController)
  }
  
  @inlinable
  public func show<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
                where VC: ViewController, OwnerVC: _ViewController
  {
    self.viewController.show(viewController, in: owner)
  }
  @inlinable
  public func showDetail<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
                where VC: ViewController, OwnerVC: _ViewController
  {
    self.viewController.showDetail(viewController, in: owner)
  }

  
  // MARK: - Hierarchy
  
  @inlinable
  public var children : [ _ViewController ] {
    set { viewController.children = newValue }
    get { viewController.children }
  }

  @inlinable
  public var parent : _ViewController? {
    set { viewController.parent = newValue }
    get { viewController.parent }
  }
  
  @inlinable
  public func willMove(toParent parent: _ViewController?) {
    viewController.willMove(toParent: parent)
  }
  
  @inlinable
  public func didMove(toParent parent: _ViewController?) {
    viewController.didMove(toParent: parent)
  }

  @inlinable
  public func addChild<VC: ViewController>(_ viewController: VC) {
    self.viewController.addChild(viewController)
  }
  @inlinable
  public func removeFromParent() {
    viewController.removeFromParent() // TBD: really unwrap?
  }

  
  // MARK: - Better Description

  @inlinable
  public var description: String { "<Any: \(viewController)>" }
  @inlinable
  public func appendAttributes(to description: inout String) {}
}
