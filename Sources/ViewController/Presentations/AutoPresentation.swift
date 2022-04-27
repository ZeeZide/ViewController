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
  
  fileprivate struct Present: View {
    
    @ObservedObject var presentingViewController : VC
    let mode : ViewControllerPresentationMode
    
    var body: some View {
      if let presentation =
          presentingViewController.activePresentation(for: mode)
      {
        let presentedViewController = presentation.viewController
        presentedViewController.anyControlledContentView
          .environment(\.viewControllerPresentationMode, mode)
          .navigationTitle(presentedViewController.navigationTitle)
      }
      else {
        TypeMismatchInfoView<AnyViewController, VC>(
          parent: presentingViewController, expectedMode: mode
        )
      }
    }
  }

  func body(content: Content) -> some View {
    // Note: Also used internally during presentation.
    content
      // Note: The `VC` class is that of the "parent" ViewController, not of the
      //       ViewController being presented!
      .sheet(
        isPresented: viewController.isPresentingMode(.sheet),
        content: {
          Present(presentingViewController: viewController, mode: .sheet)
        }
      )
      .background(
        NavigationLink(
          isActive: viewController.isPresentingMode(.navigation),
          destination: {
            Present(presentingViewController: viewController, mode: .navigation)
          },
          label: { Color.clear } // TBD: EmptyView?
        )
      )
    
      .viewControllerDebugOverlay()
  }
}
