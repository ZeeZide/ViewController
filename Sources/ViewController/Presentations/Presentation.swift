//
//  Presentation.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension ViewController {
  
  @inlinable
  func willAppear()    {}

  @inlinable
  func willDisappear() {}
  
  @inlinable
  var presentedViewController  : _ViewController? {
    // Really a set in our case ...
    activePresentations.first?.viewController
  }
}

public extension _ViewController {
  
  func activePresentation(for mode: PresentationMode?)
       -> ViewControllerPresentation?
  {
    guard let mode = mode else { return activePresentations.first }
    return activePresentations.first(where: { $0.mode == mode })
  }
  func activePresentation(for presentedViewController: _ViewController)
       -> ViewControllerPresentation?
  {
    activePresentations.first { $0.viewController === presentedViewController }
  }

  // MARK: - Bindings
  
  /**
   * This allows us to check whether a particular VC is being presented,
   * e.g. in case the presentation should be done differently (e.g. sheet vs
   * navigation).
   */
  @inlinable
  func isPresenting(mode: ViewControllerPresentationMode?,
                    _ condition: @escaping ( _ViewController ) -> Bool)
       -> Binding<Bool>
  {
    Binding(
      get: {
        guard let presentation = self.activePresentation(for: mode) else {
          return false
        }
        if let mode = mode, mode != presentation.mode { return false }
        return condition(presentation.viewController)
      },
      set: { isShowing in
        // We cannot make VCs "appear", that would require a factory.
        // Instead, the factory part is provided using the presentation mode
        // helpers.
        guard !isShowing else { return } // isShowing=true would be activation
        
        guard let presentation = self.activePresentation(for: mode) else {
          // This is fine, could have happened by other means.
          return logger.debug("Did not find VC to deactivate: \(self)")
        }

        assert(mode != .automatic)
        assert(presentation.mode != .automatic)
        if let mode = mode, presentation.mode != mode { return }
        
        /// Does our condition match?
        guard condition(presentation.viewController) else { return }
        
        logger.debug(
          "Binding dismiss: \(presentation.viewController.description)")
        presentation.viewController.dismiss()
      }
    )
  }

  /**
   * Only checks whether a specific mode is active. This is used for the
   * internally supported "auto" modes (`.sheet` and `.navigation`).
   */
  @inlinable
  func isPresentingMode(_ mode: ViewControllerPresentationMode)
       -> Binding<Bool>
  {
    // In here, `.pushLink` and `.navigation` must be treated differently!
    // Only during presentation, we may need to dismiss the other type!
    Binding(
      get: {
        self.activePresentations.contains(where: { $0.mode == mode })
      },
      set: { isShowing in
        // We cannot make VCs "appear", that would require a factory.
        // Instead, the factory part is provided using the presentation mode
        // helpers.
        guard !isShowing else {
          // isShowing=true would be activation
          if self.activePresentations.contains(where: { $0.mode == mode }) {
            logger.debug(
              "Attempt to activate VC via Binding, mode already active!")
          }
          else {
            // FIXME: This can sometimes be seen in sheets, figure out why
            logger.warning(
              "Attempt to activate VC via Binding, won't work \(self)!")
          }
          return
        }
        
        // Dismiss if the presentation mode matches
        
        guard let presentation = self.activePresentation(for: mode) else {
          // This is fine, could have happened by other means.
          return logger.debug("did not find VC to deactivate \(self)?")
        }

        /// If a mode was requested, make sure it is the right one.
        /// TBD: what about "automatic" and such? Never active in an actual
        ///      presentation!
        assert(presentation.mode == mode, "internal inconsistency!")
        guard presentation.mode == mode else { return }

        logger.debug(
          "Dismiss by mode binding: \(presentation.viewController.description)")
        presentation.viewController.dismiss()
      }
    )
  }

  /**
   * Lookup a presented ``ViewController`` of a particular type. Returns nil
   * if there is none such (or the mode doesn't match)
   *
   * E.g. this is used by the SheetPresentation.
   */
  @inlinable
  func presentedViewController<VC>(of type: VC.Type,
                                   mode: ViewControllerPresentationMode?)
       -> VC?
    where VC: ViewController
  {
    guard let presentation = activePresentation(for: mode) else { return nil }
    if let mode = mode, mode != presentation.mode    { return nil }
    return presentation.viewController as? VC
  }
  
  
  /**
   * This allows us to check whether a particular type of VC is being presented,
   * e.g. in case the presentation should be done differently (e.g. sheet vs
   * navigation).
   *
   * CAREFUL: This only checks the type, there could be multiple presentations
   *          with the same type! (leading to multiple Bindings being true,
   *          and different ContentViews being active, potentially capturing the
   *          wrong environment).
   */
  func isPresenting<VC>(_ controllerType: VC.Type,
                        mode: ViewControllerPresentationMode?)
       -> Binding<Bool>
         where VC: ViewController
  {
    isPresenting(mode: mode) { $0 is VC }
  }


  // MARK: - API Methods

  @inlinable
  func show<VC: ViewController>(_ viewController: VC) {
    show(viewController, in: self)
  }
  @inlinable
  func showDetail<VC: ViewController>(_ viewController: VC) {
    showDetail(viewController, in: self)
  }
  
  @inlinable
  func show<VC: ViewController>(_ viewController: VC)
         where VC.ContentView == DefaultViewControllerView
  {
    present(viewController)
  }
  
  @inlinable
  func showDetail<VC: ViewController>(_ viewController: VC)
         where VC.ContentView == DefaultViewControllerView
  {
    show(viewController)
  }

  @inlinable
  func present<VC: ViewController>(_ viewController: VC) {
    defaultPresent(viewController, mode: .automatic)
  }
  
  @inlinable
  func present<VC>(_ viewController: VC, mode: PresentationMode)
         where VC: ViewController
  {
    defaultPresent(viewController, mode: mode)
  }

  /**
   * Present a ``ViewController`` that doesn't have a
   * ``ViewController/ContentView`` assigned.
   */
  @inlinable
  func present<VC: ViewController>(_ viewController: VC)
         where VC.ContentView == DefaultViewControllerView
  {
    // Requires a custom `PushPresentation` or `SheetPresentation`
    defaultPresent(viewController, mode: .custom)
  }


  // MARK: - Present Implementation

  @inlinable
  func show<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
         where VC: ViewController, OwnerVC: _ViewController
  {
    if let handler = presentingViewController ?? parent {
      return handler.show(viewController, in: owner)
    }
    owner.present(viewController) // fallback to `present`
  }
  @inlinable
  func showDetail<VC, OwnerVC>(_ viewController: VC, in owner: OwnerVC)
         where VC: ViewController, OwnerVC: _ViewController
  {
    if let handler = presentingViewController ?? parent {
      return handler.showDetail(viewController, in: owner)
    }
    owner.show(viewController) // fallback to `show`
  }

  func modalPresentationMode<VC>(for viewController: VC) -> PresentationMode
         where VC: ViewController
  {
    // Check if the ViewController being presented explicitly requested a
    // certain style
    let desiredStyle = viewController.modalPresentationStyle
    if desiredStyle != .automatic { return desiredStyle }
      
    if VC.ContentView.self == DefaultViewControllerView.self {
      // Requires an explicit ``PushPresentation`` or ``SheetPresentation`` in
      // the associated `View`.
      return .custom
    }
    
    return .sheet
  }

  func defaultPresent<VC>(_ viewController: VC, mode: PresentationMode)
         where VC: ViewController
  {
    guard viewController !== self else {
      logger.error("Attempt to present a VC in itself: \(self), \(mode)")
      assert(viewController !== self, "attempt to present a VC in itself")
      return
    }
    
    let mode = mode != .automatic
             ? mode // an explicit mode was requested
             : modalPresentationMode(for: viewController)
    
    // the very same VC is already being presented
    guard presentedViewController !== viewController else {
      logger.warning("Already presenting VC: \(viewController) in: \(self)")
      assertionFailure("already presenting VC")
      return
    }
    
    if let activePresentation = self.activePresentation(for: mode) {
      // This is OK. On iPad landscape activation is out of order. E.g. when
      // switching from link A to B, the binding first sets B to true! before
      // setting A to false.
      logger.debug("Already presenting VC in: \(self) new: \(viewController)")
      activePresentation.viewController.dismiss()
    }
    
    activePresentations.append(ViewControllerPresentation(
      viewController: viewController,
      mode: mode
    ))
    viewController.presentingViewController = self
    viewController.willAppear() // it is still not on screen

    logger.debug("Presented: \(viewController) in: \(self)")
  }
  
  func dismiss() {
    guard let parentVC = presentingViewController else {
      logger.warning("Dismiss of: \(self) but no `presentingViewController`?")
      assertionFailure("No parent VC?")
      return
    }
    
    defer { presentingViewController = nil }
    
    guard let presentation = parentVC.activePresentation(for: self) else {
      logger.warning(
        "Dismiss of: \(self), but not being presented in parent")
      assertionFailure("VC dismiss not being presented")
      return
    }
    
    assert(presentation.viewController === self,
           "VC dismiss other being presented")
    
    self.willDisappear()
    parentVC.activePresentations.removeAll {
      assert($0.viewController !== self || $0.mode == presentation.mode,
             "Same VC active in different modes!")
      return $0.viewController === self
    }
    logger.debug("Dismissed: \(self) from: \(parentVC.description)")
  }
}
