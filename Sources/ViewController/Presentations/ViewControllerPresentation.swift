//
//  ViewControllerPresentation.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import Foundation

/**
 * A `ViewControllerPresentation` holds the currently active presentation
 * within a ``ViewController``.
 *
 * It gets created when the user calls ``ViewController/present`` and friends.
 *
 * Note that a controller may hold multiple presentations, e.g. it may present
 * a detail in a `NavigationView` while also doing a presentation in a sheet.
 *
 * This is the type erased version, ``TypedViewControllerPresentation`` is
 * created internally.
 */
public protocol ViewControllerPresentation {
  
  var viewController : _ViewController                { get }
  var mode           : ViewControllerPresentationMode { get }
  
  var contentView    : () -> AnyView { get }
}

/**
 * The concrete ``ViewControllerPresentation`` object used internally.
 */
public struct TypedViewControllerPresentation<VC: ViewController>
              : ViewControllerPresentation
{
  
  public let viewController : _ViewController
  public let mode           : ViewControllerPresentationMode
  public let contentView    : () -> AnyView
  
  init(viewController: VC, mode: ViewControllerPresentationMode) {
    self.viewController = viewController
    self.mode           = mode
    self.contentView    = { viewController.anyControlledContentView }
  }
}

