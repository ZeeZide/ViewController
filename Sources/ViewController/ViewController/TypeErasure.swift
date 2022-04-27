//
//  TypeErasure.swift
//  ViewController
//
//  Created by Helge Heß on 26.04.22.
//

import SwiftUI

public extension ViewController {
  
  @inlinable
  var anyContentView           : AnyView { AnyView(contentView) }

  @inlinable
  var anyControlledContentView : AnyView { AnyView(controlledContentView) }

  @inlinable
  var anyRepresentedObject : Any? {
    set { representedObject = newValue as? RepresentedValue }
    get { representedObject }
  }
}
