//
//  Title.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

public extension ViewController {
  
  @inlinable
  var navigationTitle : String { title ?? defaultNavigationTitle }
  
  /**
   * Returns a navigation title based on the ``ViewController``s type name.
   */
  @inlinable
  var defaultNavigationTitle: String {
    let typeName = "\(type(of: self))"
    
    let cutName  : String = {
      if typeName.hasSuffix("ViewController") {
        return String(typeName.dropLast(14))
      }
      else if typeName.hasSuffix("VC") {
        return String(typeName.dropLast(14))
      }
      else {
        return typeName
      }
    }()
    
    if let idx = cutName.firstIndex(of: ".") {
      return String(cutName[cutName.index(after: idx)...])
    }
    
    return cutName
  }

  
  @available(*, deprecated, renamed: "navigationTitle")
  @inlinable
  var navigationBarTitle : String { navigationTitle }
}
