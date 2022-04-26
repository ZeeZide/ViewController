//
//  SheetPresentation.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension View {

  /**
   * Controls how a specific ViewController is being presented in `.custom`
   * mode.
   *
   * It does NOT do the actual presentation! I.e. `.present(MyViewController)`
   * still has to be called.
   *
   * This peeks into the ``ViewController/presentedVC`` of the current
   * ``ViewController`` (which is stored in the environment!)
   *
   * How to use:
   * ```
   * ContentView()
   *   .presentInSheet(WidgetViewVC.self) {
   *     NavigationView {
   *       ChildView()
   *     }
   *     .navigationViewStyle(.stack)
   *   }
   *   .presentInSheet(AddWidgetVC.self) {
   *     AddWidgetVC.ContentView()
   *   }
   *   .presentInSheet(ViewConfigVC.self) {
   *     AddWidgetVC.ContentView()
   *   }
   * ```
   */
  func presentInSheet<VC, V>(_ vc: VC.Type,
                             @ViewBuilder content: @escaping () -> V)
       -> some View
       where VC: ViewController, V: View
  {
    // Note: The explicit specialization is NECESSARY, otherwise the wrong ones
    //       are picked up!
    /*
     * This has issues in the content closure:
     * .presentInSheet(ConfigVC.self) {
     *   // Passing parameters (like `widget`) here, ends up w/ the "first"
     *   // widget of the type.
     *   ConfigVC.ContentView()
     * }
     * Environment objects do seem to be fine though? So something strange
     * happening w/ the capture here.
     */
    self.modifier(SheetPresentation<VC, V>(destination: content))
  }

  /**
   * Controls how a specific ``ViewController`` is being presented in `.custom`
   * mode.
   *
   * It does NOT do the actual presentation! I.e. `.present(MyViewController)`
   * still has to be called.
   *
   * This peeks into the ``ViewController/presentedVC`` of the current
   * ``ViewController`` (which is stored in the environment!)
   *
   * How to use:
   * ```
   * ContentView()
   *   .presentInSheet(WidgetViewVC.self)
   *   .presentInSheet(AddWidgetVC.self)
   *   .presentInSheet(ViewConfigVC.self)
   * ```
   */
  @inlinable
  func presentInSheet<VC: ViewController>(_ vc: VC.Type) -> some View {
    presentInSheet(vc, content: { RenderContentView<VC>() })
  }

  /**
   * Helper to avoid using ``presentInSheet`` with a ``ViewController``
   * that doesn't have a proper ``ContentView``.
   */
  @available(*, unavailable,
             message: "The ViewController needs a proper `ContentView`")
  func presentInSheet<VC: ViewController>(_ vc: VC.Type) -> some View
         where VC.ContentView == DefaultViewControllerView
  {
    presentInSheet(vc, content: { RenderContentView<VC>() })
  }
}
  
/**
 * Controls how a specific ViewController is being presented in `.custom` mode.
 * It does NOT do the actual presentation!
 *
 * This peeks into the ``ViewController/presentedVC`` of the current
 * ``ViewController`` (which is stored in the environment!)
 *
 * How to use:
 * ```
 * ContentView()
 *   .presentInSheet(WidgetViewVC.self) {
 *     NavigationView {
 *       ChildView()
 *     }
 *     .navigationViewStyle(.stack)
 *   }
 *   .presentInSheet(AddWidgetVC.self) {
 *     AddWidgetVC.ContentView()
 *   }
 *   .presentInSheet(ViewConfigVC.self) {
 *     AddWidgetVC.ContentView()
 *   }
 * ```
 */
@usableFromInline
struct SheetPresentation<DestinationVC, V>: ViewModifier
         where DestinationVC: ViewController, V: View
{
  
  @EnvironmentObject private var parent : AnyViewController
  
  private let destination : () -> V
  private let mode        : ViewControllerPresentationMode
  
  public init(destination: @escaping () -> V) {
    self.destination = destination
    self.mode = .custom
  }
  @usableFromInline
  internal init(mode: ViewControllerPresentationMode,
                destination: @escaping () -> V)
  {
    self.destination = destination
    self.mode        = mode
  }
  
  private func isActive(_ vc: _ViewController) -> Bool {
    // TODO: This needs an optional extra condition
    vc is DestinationVC
  }
  
  @usableFromInline
  func body(content: Content) -> some View {
    content
      .sheet(isPresented: parent.isPresenting(mode: mode, isActive)) {
        if let presentedVC : DestinationVC = parent
            .presentedViewController(of: DestinationVC.self, mode: mode)
        {
          // TODO: This is tricky. The destination here can capture
          //       the incorrect VC, because the sheet presentation condition
          //       only checks the type!
          destination()
            .environment(\.viewControllerPresentationMode, .sheet)
            .controlled(by: presentedVC)
        }
        else {
          TypeMismatchInfoView<DestinationVC, AnyViewController>(
            parent: parent, expectedMode: mode
          )
        }
      }
  }
}
