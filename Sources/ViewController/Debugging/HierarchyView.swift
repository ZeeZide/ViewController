//
//  HierarchyView.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

#if DEBUG
struct HierarchyView: View {
  
  let title       : String
  let controllers : [ _ViewController ]
  
  var body: some View {
    if controllers.count > 1 {
      Divider()
      VStack(alignment: .leading, spacing: 16) {
        Text(title)
          .font(.title2)
        
        VStack(alignment: .leading, spacing: 12) {
          // Don't do this at home
          ForEach(Array(zip(controllers.indices, controllers)), id: \.0) {
            ( idx, parent ) in
            HStack(alignment: .firstTextBaseline) {
              Text("\(idx)")
              Text(verbatim: "\(parent)")
            }
          }
        }
        .padding(.horizontal)
      }
      .padding()
    }
  }
}
#endif // DEBUG
