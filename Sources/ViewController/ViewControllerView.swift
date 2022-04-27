//
//  ViewControllerView.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * A View that can be instantiated w/o further arguments.
 *
 * This is used within ``ViewController``s, to instantiate their
 * ``ViewController/ContentView``.
 */
public protocol ViewControllerView: View {
  init()
}

extension EmptyView: ViewControllerView {}


#if true // This Works

  public typealias DefaultViewControllerView = EmptyView

#else // 2022-04-24: This Segfaults swiftc in Xcode 13.3

  #if DEBUG
    public struct DefaultViewControllerView: View {
      @Environment(\.viewController) private var viewController

      @usableFromInline
      init() { assertionFailure("No VC View is defined!") }
      
      public var body: some View {
        VStack {
          Label("Missing VC View", systemImage: "questionmark.circle")
          Spacer()
          if let viewController = viewController {
            Text(verbatim: "Class: \(type(of: viewController))")
            Text(verbatim: "ID: \(ObjectIdentifier(viewController))")
            Text(verbatim: "\(viewController)")
          }
          else {
            Text("No VC set in environment?!")
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
  #else
    public struct DefaultViewControllerView: View {
      public var body: some View {
        // TODO: report issue etc? (using bug reporter link in Info.plist?)
        Label("Missing VC View", systemImage: "questionmark.circle")
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
  #endif
#endif
