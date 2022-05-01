//
//  DefaultDescription.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

extension _ViewController {
  
  internal var oidString : String {
    String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
  }
  
  internal var typeName : String { String(describing: type(of: self)) }
}

extension ViewController { // MARK: - Description
  
  public var description: String {
    var ms   = "<\(typeName)[\(oidString)]:"
    appendAttributes(to: &ms)
    ms += ">"
    return ms
  }

  @inlinable
  public func appendAttributes(to description: inout String) {
    defaultAppendAttributes(to: &description)
  }

  public func defaultAppendAttributes(to description: inout String) {
    // public, so that subclasses can call this "super" implementation!
    if let v = title { description += " '\(v)'" }
    assert(self !== presentedViewController)
    
    if activePresentations.count == 1, let v = activePresentations.first {
      let vc = "\(v.viewController.typeName)[\(v.viewController.oidString)]"
      switch v.mode {
        case .automatic:
          assertionFailure("Unexpected presentation mode: \(v)")
          description += " presenting[AUTO!!]=\(vc)"
        case .custom     : description += " presenting[CUSTOM]=\(vc)"
        case .sheet      : description += " presenting[sheet]=\(vc)"
        case .navigation : description += " presenting[nav]=\(vc)"
        case .pushLink   : description += " presenting[link]=\(vc)"
      }
    }
    else if !activePresentations.isEmpty {
      description += " presenting=#\(activePresentations.count)"
    }
  }
}
