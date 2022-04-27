//
//  RepresentedObject.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import Combine

public extension ViewController {
  
  @inlinable
  var representedObject : RepresentedValue? {
    set {
      if let storage = storageIfAvailable {
        storage.representedObject = newValue
      }
      else if let value = newValue {
        self.storage.representedObject = value
      }
    }
    get { storageIfAvailable?.representedObject }
  }
}

public extension ViewController
  where RepresentedValue: ObservableObject,
        RepresentedValue.ObjectWillChangePublisher == ObservableObjectPublisher
{
  // A variant which subscribes to the representedObject if it is an
  // ObservableObject. Needs a test.
  
  @inlinable
  var representedObject : RepresentedValue? {
    set {
      if let storage = storageIfAvailable {
        guard newValue !== storage.representedObject else { return } // same
        storage.representedObjectSubscription = nil
        storage.representedObject = newValue
        storage.representedObjectSubscription =
          newValue?.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
          }
      }
      else if let value = newValue {
        storage.representedObject = value
        storage.representedObjectSubscription =
          newValue?.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
          }
      }
    }
    get { storageIfAvailable?.representedObject }
  }
}
