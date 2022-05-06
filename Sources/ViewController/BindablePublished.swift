//
//  ViewControllerState.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import Combine
import SwiftUI

// Unfortunatly this doesn't work, presumably swiftc gets confused in
// VC lookup (it doesn't find the static subscripts and ends up in the
// unavailable warnings).
// If the same typealias is done within the final VC itself, then it works.
#if false
extension ViewController {
  
  /**
   * Override the SwiftUI `State` property with our own inside
   * ``ViewController``'s.
   *
   * Example:
   * ```swift
   * class TitleChangePage: ViewController {
   *
   *   @State var title = "To be changed!"
   *
   *   var view: some View {
   *     TextField("Change me", $title)
   *   }
   * }
   * ```
   */
  public typealias State = BindablePublished
}
#endif

/**
 * A version of `@Published` that has a `Binding` as its `projectedValue`,
 * allowing directs binds to the object.
 *
 * Example:
 * ```swift
 * class TitleChangePage: ViewController {
 *
 *   @BindablePublished var title = "To be changed!"
 *
 *   var view: some View {
 *     TextField("Change me", $title)
 *   }
 * }
 * ```
 */
@propertyWrapper
public struct BindablePublished<Value> {
  // https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/
  // https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#referencing-the-enclosing-self-in-a-wrapper-type

  @usableFromInline
  var storage: Value

  @inlinable
  public init(wrappedValue: Value) { self.storage = wrappedValue }
  
  
  // MARK: - Static Subscripts

  @inlinable
  public static subscript<T: ObservableObject>(
    _enclosingInstance instance: T,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
  )
  -> Value
  where T.ObjectWillChangePublisher == ObservableObjectPublisher
  {
    get { instance[keyPath: storageKeyPath].storage }
    set {
      instance.objectWillChange.send()
      instance[keyPath: storageKeyPath].storage = newValue
    }
  }

  // https://github.com/apple/swift/blob/223d73cc470d2395b3d55d07eaf6866e7f6171f9/lib/Sema/TypeCheckPropertyWrapper.cpp#L391
  @inlinable
  public static subscript<T: ObservableObject>(
    _enclosingInstance instance: T,
    projected projectedKeyPath : KeyPath<T, Binding<Value>>,
    storage   storageKeyPath   : ReferenceWritableKeyPath<T, Self>
  )
  -> Binding<Value>
  where T.ObjectWillChangePublisher == ObservableObjectPublisher
  {
    return Binding(
      get: { instance[keyPath: storageKeyPath].storage },
      set: { instance[keyPath: storageKeyPath].storage = $0 }
    )
  }
  
  
  // - MARK: Private Properties

  @available(*, unavailable,
             message: "`@BindablePublished` only works w/ ObservableObject's")
  @inlinable
  public var wrappedValue: Value {
    get { fatalError() }
    set { fatalError() }
  }

  @available(*, unavailable,
              message: "`@BindablePublished` only works w/ ObservableObject's")
  @inlinable
  public var projectedValue: Binding<Value> { fatalError() }
}
