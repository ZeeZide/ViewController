//
//  TypeMismatchInfoView.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

@usableFromInline
struct TypeMismatchInfoView<DestinationVC, ParentVC>: View
         where DestinationVC: ViewController, ParentVC: ViewController
{
  
  @ObservedObject private var parent : ParentVC
  private let expectedMode : ViewControllerPresentationMode

  @usableFromInline
  init(parent: ParentVC, expectedMode: ViewControllerPresentationMode) {
    self.parent       = parent
    self.expectedMode = expectedMode
  }

  @usableFromInline
  var body: some View {
    VStack {
      Label("Type Mismatch",
            systemImage: "exclamationmark.triangle")
        .font(.title)
        .padding()
        .foregroundColor(.red)

      HStack(alignment: .firstTextBaseline) {
        Text("Parent:")
        Spacer()
        Text(verbatim: parent.description)
      }
      .padding()

      if parent.activePresentations.isEmpty {
        Text("No presentation active?")
          .padding()
          .foregroundColor(.red)
          .font(.body.bold())
      }
      else {
        ForEach(Array(zip(parent.activePresentations.indices,
                          parent.activePresentations)), id: \.0)
        { _, presentation in
          HStack(alignment: .firstTextBaseline) {
            Text("Presented:")
            Spacer()
            Text(verbatim: presentation.viewController.description)
          }
          .padding()
          HStack(alignment: .firstTextBaseline) {
            Text("Mode:")
            Spacer()
            Text(verbatim: "\(presentation.mode)")
          }
        }
        .padding()
      }
      
      Spacer()
    }
  }
}
