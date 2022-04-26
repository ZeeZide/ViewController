//
//  DefaultDescription.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

extension ViewController { // MARK: - Description
  
  @inlinable
  public var description: String {
    let addr = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms   = "<\(type(of: self))[\(addr)]:"
    appendAttributes(to: &ms)
    ms += ">"
    return ms
  }

  @inlinable
  public func appendAttributes(to description: inout String) {
    defaultAppendAttributes(to: &description)
  }

  @inlinable
  public func defaultAppendAttributes(to description: inout String) {
    // public, so that subclasses can call this "super" implementation!
    if let v = title { description += " '\(v)'" }
    assert(self !== presentedViewController)
    
    if activePresentations.count == 1, let v = activePresentations.first {
      description += " presenting=\(v.viewController)[\(v.mode)]"
    }
    else if !activePresentations.isEmpty {
      description += " presenting=#\(activePresentations.count)"
    }
  }
}
