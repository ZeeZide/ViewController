//
//  DebugOverlay.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

#if DEBUG

@usableFromInline
struct DebugOverlayModifier: ViewModifier {

  @Environment(\.viewControllerDebugMode) private var mode
  @State private var showingOverlay = false

  
  /// Show information about the VC active in the environment
  struct InfoPanel: View { // TBD: Make it a VC? :-)

    @Binding var isShowing : Bool
    @EnvironmentObject private var viewController : AnyViewController
    
    private func dismiss() { isShowing = false }
    
    #if os(macOS)
      var body: some View {
        NavigationView {
          ViewControllerInfo(
            watchChanges: viewController,
            viewController: viewController
          )
          .navigationTitle(viewController.navigationTitle)
          .toolbar {
            Button(action: dismiss) {
              Label("Close", systemImage: "xmark.circle")
            }
          }
        }
      }
    #else
      var body: some View {
        NavigationView {
          ViewControllerInfo(
            watchChanges: viewController,
            viewController: viewController
          )
          .navigationTitle(viewController.navigationTitle)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            Button(action: dismiss) {
              Label("Close", systemImage: "xmark.circle")
            }
          }
        }
      }
    #endif
  }
  
  private func showOverlay() {
    showingOverlay = true
  }
    
  @usableFromInline
  func body(content: Content) -> some View {
    content
      .overlay(
        Button(action: showOverlay) {
          Image(systemName: "ladybug")
            .accessibilityLabel("Show Debug Overlay")
            .foregroundColor(.red)
        }
        .labelsHidden()
        .sheet(isPresented: $showingOverlay) {
          InfoPanel(isShowing: $showingOverlay)
        }
        .opacity(mode == .overlay ? 1.0 : 0.0)
        .padding(), alignment: .bottomTrailing
      )
  }
}

public extension View {
  
  func viewControllerDebugOverlay() -> some View {
    self.modifier(DebugOverlayModifier())
  }
}

#else // non-DEBUG fallback

public extension View {
  
  @inlinable
  func viewControllerDebugOverlay() -> some View {
    self
  }
}

#endif
