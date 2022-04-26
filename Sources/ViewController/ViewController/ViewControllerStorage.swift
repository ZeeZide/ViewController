//
//  ViewControllerStorage.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import Foundation
import Combine

// Why all this Storage mess? Because we'd really like to keep `ViewController`
// a protocol and not introduce a `ViewControllerBase` like object to provide
// persistence for implementors.


// MARK: - Forwarders (Peek and pop from the associated storage class)

public extension ViewController {
  
  // TODO: Make a nice keypath subscript for the repetitive code

  @inlinable
  var title : String? {
    set {
      if let storage = storageIfAvailable { storage.title = newValue }
      else if let value = newValue        { storage.title = value    }
    }
    get { storageIfAvailable?.title }
  }

  
  // MARK: - Presentation

  @inlinable
  var modalPresentationStyle: ViewControllerPresentationMode {
    set {
      if let storage = storageIfAvailable {
        storage.modalPresentationStyle = newValue
      }
      else if newValue != .automatic {
        storage.modalPresentationStyle = newValue
      }
    }
    get { storageIfAvailable?.modalPresentationStyle ?? .automatic }
  }

  @inlinable
  var activePresentations : [ ViewControllerPresentation ] {
    set {
      if let storage = storageIfAvailable { storage.presentations = newValue }
      else if !newValue.isEmpty           { storage.presentations = newValue }
    }
    get { storageIfAvailable?.presentations ?? [] }
  }
  
  @inlinable
  var presentingViewController : _ViewController? {
    set {
      if let storage = storageIfAvailable {
        storage.presentingViewController = newValue
      }
      else if let value = newValue {
        storage.presentingViewController = value
      }
    }
    get { storageIfAvailable?.presentingViewController }
  }


  // MARK: - Hierarchy

  @inlinable
  var children : [ _ViewController ] {
    set {
      if let storage = storageIfAvailable {
        storage.childViewControllers = newValue
      }
      else if !newValue.isEmpty {
        self.storage.childViewControllers = newValue
      }
    }
    get { storageIfAvailable?.childViewControllers ?? [] }
  }
  
  @inlinable
  var parent : _ViewController? {
    set {
      if let storage = storageIfAvailable {
        storage.parentViewController = newValue
      }
      else if let value = newValue {
        self.storage.parentViewController = value
      }
    }
    get { storageIfAvailable?.parentViewController }
  }
}


// MARK: - Holder Class

/**
 * An internal state holder class used to associated some default properties
 * with a VC.
 * This is done to keep ``ViewController`` as a protocol.
 * Alternative: Keep ``ViewController`` as a protocol, but add
 *              ``ViewControllerBase`` as a base class.
 *
 * To access the storage of the ViewController, use
 * ``ViewController/storage`` or ``ViewController/storageIfAvailable``.
 */
@usableFromInline
internal class ViewControllerStorage<VC>: NSObject where VC: ViewController {
  // So the important point here is to emit changes!
  
  weak var viewController : VC?
  
  init(_ viewController: VC) { self.viewController = viewController }
  
  @usableFromInline
  internal var representedObject : VC.RepresentedValue? {
    willSet { viewController?.objectWillChange.send() }
  }
  @usableFromInline
  internal var representedObjectSubscription: AnyCancellable?

  
  // MARK: - Title

  @usableFromInline
  internal var title : String? {
    willSet { viewController?.objectWillChange.send() }
  }
  
  
  // MARK: - Presentation
  
  // no change event needed for this?
  @usableFromInline
  internal var modalPresentationStyle = ViewControllerPresentationMode.automatic

  @usableFromInline
  internal var presentations : [ ViewControllerPresentation ] = [] {
    willSet {
      if presentations.count == newValue.count {
        if newValue.isEmpty { return } // both empty, do not emit
        
        if !zip(presentations, newValue).contains(where: { lhs, rhs in
          lhs.viewController !== rhs.viewController || lhs.mode != rhs.mode
        }) { return } // same
      }
      
      viewController?.objectWillChange.send()
    }
  }

  @usableFromInline
  internal weak var presentingViewController : _ViewController?

  
  // MARK: - Hierarchy

  @usableFromInline
  internal var childViewControllers = [ _ViewController ]() {
    willSet {
      guard childViewControllers.map({ ObjectIdentifier($0) })
            != newValue.map({ ObjectIdentifier($0) }) else { return }
      viewController?.objectWillChange.send()
    }
  }

  @usableFromInline
  internal weak var parentViewController : _ViewController?

  
  // MARK: - Subscriptions
  
  /**
   * ViewController's as ObservableObject's very often depend on some model
   * objects or other publishers.
   * This provides a default storage for such.
   */
  @usableFromInline
  internal var subscriptions : Set<AnyCancellable>?
}


// MARK: - Associated Object

fileprivate var associatedObjectToken = 42

internal extension ViewController {
  
  /**
   * Returns the associated storage for the ``ViewController``,
   * i.e. the place where the protocol puts the tracking state.
   *
   * If the ViewController doesn't have storage yet, it gets allocated and
   * assigned.
   *
   * Use ``ViewController/storageIfAvailable`` to avoid storage allocation.
   */
  @usableFromInline
  var storage : ViewControllerStorage<Self> {
    get {
      if let storage = storageIfAvailable { return storage }
      let storage = ViewControllerStorage<Self>(self)
      storageIfAvailable = storage
      return storage
    }
  }
  
  /**
   * Returns the associated storage for the ``ViewController``,
   * i.e. the place where the protocol puts the tracking state.
   *
   * If the ViewController doesn't have storage yet, nil is returned.
   *
   * Use ``ViewController/storage`` to allocate storage on demand.
   */
  @usableFromInline
  var storageIfAvailable : ViewControllerStorage<Self>? {
    set {
      assert(newValue != nil, "Attempt to clear VC storage?!")
      objc_setAssociatedObject(self, &associatedObjectToken, newValue,
        .OBJC_ASSOCIATION_RETAIN)
    }
    get {
      guard let value = objc_getAssociatedObject(self, &associatedObjectToken) else {
        return nil
      }
      assert(value is ViewControllerStorage<Self>,
             "Unexpected storage associated w/ ViewController \(value) \(self)")
      return value as? ViewControllerStorage<Self>
    }
  }
}
