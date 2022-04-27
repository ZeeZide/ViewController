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
 */
public struct ViewControllerPresentation {
  
  public let viewController : _ViewController
  public let mode           : ViewControllerPresentationMode

  init<VC>(viewController: VC, mode: ViewControllerPresentationMode)
    where VC: ViewController
  {
    self.viewController = viewController
    self.mode           = mode
  }
}
