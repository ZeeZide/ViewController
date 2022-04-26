//
//  AutoPresentation.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * This is used by `controlled(by:)` to attach the logic to present the
 * "automatic" presentations in sheets or `NavigationView`s.
 *
 * It watches the current VC to detect presentation changes,
 * and binds the sheet/navlink to the respective mode.
 */
struct AutoPresentationViewModifier<VC>: ViewModifier where VC: ViewController {
  
  @ObservedObject var viewController : VC

  func body(content: Content) -> some View {
    // Note: Also used internally during presentation.
    content
      // Note: The `VC` class is that of the "parent" ViewController, not of the
      //       ViewController being presented!
      .sheet(
        isPresented: viewController.isPresentingMode(.sheet),
        content: {
          if let presentation = viewController.activePresentation(for: .sheet) {
            presentation.contentView()
              .environment(\.viewControllerPresentationMode, .sheet)
              .navigationTitle(presentation.viewController.navigationTitle)
          }
          else {
            TypeMismatchInfoView<AnyViewController, VC>(
              parent: viewController, expectedMode: .sheet
            )
          }
        }
      )
      .background(
        NavigationLink(
          isActive: viewController.isPresentingMode(.navigation),
          destination: {
            if let presentation = viewController
                      .activePresentation(for: .navigation)
            {
              presentation.contentView()
                .environment(\.viewControllerPresentationMode, .navigation)
                .navigationTitle(presentation.viewController.navigationTitle)
            }
            else {
              TypeMismatchInfoView<AnyViewController, VC>(
                parent: viewController, expectedMode: .navigation
              )
            }
          },
          label: { Color.clear } // TBD: EmptyView?
        )
      )
    
      .viewControllerDebugOverlay()
  }
}
