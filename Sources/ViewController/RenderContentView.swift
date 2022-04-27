//
//  RenderContentView.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Accesses the `view` of the current viewController of the specific class.
 *
 * User level code usually doesn't need to work with this.
 *
 * Example:
 * ```swift
 * var body: some View {
 *   // Note: The environment needs to have `SettingsPage`!
 *   RenderContentView<SettingsPage>()
 * }
 * ```
 */
public struct RenderContentView<VC: ViewController>: View {
  
  @usableFromInline
  @EnvironmentObject var viewController : VC

  @inlinable
  public init() {}
  
#if DEBUG
  @inlinable
  public var body: some View {
    if viewController.view is EmptyView {
      Text(verbatim: "Embedding EmptyView?")
        .foregroundColor(.red)
    }
    viewController.view
  }
#else
  @inlinable
  public var body: some View {
    viewController.view
  }
#endif
}
