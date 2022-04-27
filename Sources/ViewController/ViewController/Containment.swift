//
//  Containment.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension ViewController {

  @inlinable
  func willMove(toParent parent: _ViewController?) {}
  @inlinable
  func didMove (toParent parent: _ViewController?) {}
}

public extension ViewController {
  
  @inlinable
  func addChild<VC: ViewController>(_ viewController: VC) {
    assert(!children.contains(where: { $0 === viewController }),
           "ViewController already contained as a child!")
    assert(viewController.parent !== self,
           "ViewController is already the parent of the child!")
    
    // Do nothing if it is the same parent (i.e. do NOT re-add)
    guard viewController.parent !== self else { return }
    
    // Remove from old parent
    if viewController.parent != nil { removeFromParent() }

    viewController.willMove(toParent: self)
    children.append(viewController)
    viewController.parent = self
    viewController.didMove(toParent: self)
  }
  
  @inlinable
  func removeFromParent() {
    guard let parent = parent else {
      return logger.warning(
        "removeFromParent() called w/o a parent being active: \(self)")
    }
    
    guard let idx = parent.children.firstIndex(where: { $0 === self }) else {
      logger.warning(
        "removeFromParent() w/o parent having the VC: \(self) \(parent.description))")
      assertionFailure("parent set to a VC, but missing from the children!")
      return
    }
    
    willMove(toParent: nil)
    parent.children.remove(at: idx)
    self.parent = nil
    didMove(toParent: nil)
  }
}
