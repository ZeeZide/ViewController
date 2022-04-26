//
//  PushPresentation.swift
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
   *   .presentInNavigation(AddWidgetVC.self) {
   *     AddWidgetVC.ContentView()
   *   }
   *   .presentInNavigation(ViewConfigVC.self) {
   *     AddWidgetVC.ContentView()
   *   }
   * ```
   *
   * Note: This is using a `background` for the `NavigationLink`.
   *        Use a ``PushLink`` for a real ``NavigationLink``.
   */
  func presentInNavigation<VC, V>(_ vc: VC.Type,
                                  @ViewBuilder content: @escaping () -> V)
       -> some View
       where VC: ViewController, V: View
  {
    // Note: The explicit specialization is NECESSARY, otherwise the wrong ones
    //       are picked up!
    self.modifier(PushPresentation<VC, V>(destination: content))
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
   *   .presentInNavigation(AddWidgetVC.self)
   *   .presentInNavigation(ViewConfigVC.self)
   * ```
   */
  @inlinable
  func presentInNavigation<VC: ViewController>(_ vc: VC.Type) -> some View {
    presentInNavigation(vc, content: { RenderContentView<VC>() })
  }

  /**
   * Helper to avoid using ``presentInNavigation`` with a ``ViewController``
   * that doesn't have a proper ``ContentView``.
   */
  @available(*, unavailable,
             message: "The ViewController needs a proper `ContentView`")
  func presentInNavigation<VC: ViewController>(_ vc: VC.Type) -> some View
         where VC.ContentView == DefaultViewControllerView
  {
    presentInNavigation(vc, content: { RenderContentView<VC>() })
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
 *   .presentInNavigation(AddWidgetVC.self) {
 *     AddWidgetVC.ContentView()
 *   }
 *   .presentInNavigation(ViewConfigVC.self) {
 *     AddWidgetVC.ContentView()
 *   }
 * ```
 *
 * Note: This is using a `background` for the `NavigationLink`.
 *        Use a ``PushLink`` for a real ``NavigationLink``.
 */
@usableFromInline
struct PushPresentation<DestinationVC, V>: ViewModifier
         where DestinationVC: ViewController, V: View
{
  
  @EnvironmentObject var parent : AnyViewController
  
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

  @usableFromInline
  func body(content: Content) -> some View {
    content
      .background(
        NavigationLink(
          // TODO: This needs an optional extra condition
          isActive: parent.isPresenting(DestinationVC.self, mode: mode),
          destination: {
            if let presentedVC =
                parent.presentedViewController(of: DestinationVC.self,
                                               mode: mode)
            {
              destination()
                .environment(\.viewControllerPresentationMode, .navigation)
                .controlled(by: presentedVC)
                .navigationTitle(presentedVC.navigationTitle)
            }
            else {
              TypeMismatchInfoView<DestinationVC, AnyViewController>(
                parent: parent, expectedMode: mode
              )
            }
          },
          label: { Color.clear } // TBD: EmptyView?
        )
      )
  }
}
