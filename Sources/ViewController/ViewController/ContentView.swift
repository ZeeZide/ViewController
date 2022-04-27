//
//  ContentView.swift
//  ViewController
//
//  Created by Helge Heß on 27.04.22.
//

import SwiftUI

public extension ViewController where ContentView: ViewControllerView {
  
  @inlinable
  @ViewBuilder var view : ContentView { ContentView() }
}

/**
 * A view used to properly refresh the contentview on VC changes.
 *
 * The ``ViewController.ContentView`` doesn't necessarily subscribe the VC
 * for changes, i.e. if used using the plain `var view` override.
 * This makes sure the `view` actually gets re-evaluated.
 */
@usableFromInline
struct ControlWrapper<VC: ViewController>: View {

  @ObservedObject fileprivate var viewController : VC
  
  @usableFromInline
  init(viewController: VC) { self.viewController = viewController }
  
  @usableFromInline
  var body : some View {
    viewController.view
      .controlled(by: viewController)
  }
}

public extension ViewController {
  
  @inlinable
  var controlledContentView : some SwiftUI.View {
    ControlWrapper(viewController: self)
  }
}
