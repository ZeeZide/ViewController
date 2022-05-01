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
internal struct AutoPresentationViewModifier<VC>: ViewModifier
                  where VC: ViewController
{
  
  @ObservedObject var viewController : VC
  
  fileprivate struct Present: View {
    
    @ObservedObject var presentingViewController : VC
    let mode : ViewControllerPresentationMode
    
    // Keep a handle to the VC being presented. We do this to avoid issue #6,
    // i.e. when a sheet is dismissed and transitions off-screen, the
    // "presentedViewController" is already gone (dismissed).
    // The `body` of this `Present` View would then evaluate to the
    // `TypeMismatchInfoView` during the dismiss.
    // So we keep the VC being presented around, to make sure we still have a
    // handle for the content-view while it is being dismissed.
    @State private var viewController : _ViewController?
    
    private var activeVC: _ViewController? {
      if let activeVC = viewController { return activeVC }

      if let presentation =
               presentingViewController.activePresentation(for: mode)
      {
        // Note: Do not modify `@State` in here! (i.e. do not push to the
        //       `viewController` variable as part of the evaluation)
        // This happens if the VC is getting presented.
        return presentation.viewController
      }

      return nil
    }

    var body: some View {
      if let presentedViewController = activeVC {
        presentedViewController.anyControlledContentView
          .environment(\.viewControllerPresentationMode, mode)
          .navigationTitle(presentedViewController.navigationTitle)
          .onAppear {
            viewController = presentedViewController
          }
          .onDisappear { // This seems to be a proper onDidDisappear
            viewController = nil
          }
      }
      else {
        #if DEBUG
          TypeMismatchInfoView<AnyViewController, VC>(
            parent: presentingViewController, expectedMode: mode
          )
        #endif
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
