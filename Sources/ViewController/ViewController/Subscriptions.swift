//
//  Subscriptions.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import Combine

public extension ViewController {
  
  /**
   * Subscribes the ViewController to changes in another ``ObservableObject``,
   * usually a "model" object.
   * If the other object emits a `willChange` event, so will the ViewController.
   *
   * Example:
   * ```swift
   * class Contacts: ViewController {
   *
   *   let contacts = ContactsStore.shared
   *
   *   init() {
   *     willChange(with: contacts)
   *   }
   * }
   * ```
   */
  @inlinable
  func willChange<T: ObservableObject>(with model: T) {
    
    let subscription = model.objectWillChange.sink { [weak self] _ in
      guard let me = self else { return }
      me.objectWillChange.send()
    }
    
    if storage.subscriptions == nil {
      storage.subscriptions = Set<AnyCancellable>()
    }
    storage.subscriptions?.insert(subscription)
  }

  /**
   * Subscribes the ViewController to changes in other ``ObservableObject``s,
   * usually "model" objects.
   * If the other object emits a `willChange` event, so will the ViewController.
   *
   * Example:
   * ```swift
   * class Contacts: ViewController {
   *
   *   let contacts  = ContactsStore.shared
   *   let calendars = CalendarsStore.shared
   *   let tasks     = TasksStore.shared
   *
   *   init() {
   *     willChange(with: contacts, calendars, tasks)
   *   }
   * }
   * ```
   */
  @inlinable
  func willChange<T1, T2, T3, T4, T5>(with model1: T1, model2: T2, model3: T3?,
                                      model4: T4?, model5: T5?)
         where T1: ObservableObject, T2: ObservableObject, T3: ObservableObject,
               T4: ObservableObject, T5: ObservableObject
  {
    willChange(with: model1)
    willChange(with: model2)
    if let model = model3 { willChange(with: model) }
    if let model = model4 { willChange(with: model) }
    if let model = model5 { willChange(with: model) }
  }
}
