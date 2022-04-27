//
//  ViewControllerInfo.swift
//  ViewController
//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH. All rights reserved.
//

#if DEBUG
import SwiftUI

struct ViewControllerInfo: View {
  
  @ObservedObject var watchChanges : AnyViewController
  let viewController : _ViewController
  
  struct TitledField<V>: View {
    let label : String
    let value : V
    
    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text(verbatim: "\(value)")
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder()
              .foregroundColor(.secondary)
              .padding(.vertical,   -4)
              .padding(.horizontal, -8)
          )
        Text(label)
          .font(.footnote)
          .foregroundColor(.secondary)
      }
    }
  }
  
  private var parentHierarchy : [ _ViewController ] {
    guard let parent = viewController.parent else { return [] }
    return Array(sequence(first: parent) { $0.parent })
  }
  
  private var presentationHierarchy : [ _ViewController ] {
    let toRoot = sequence(first: viewController) {
      $0.presentingViewController
    }
    if let presented = viewController.presentedViewController {
      let downwards = sequence(first: presented) {
        $0.presentedViewController
      }
      return Array(toRoot) + Array(downwards)
    }
    else {
      return Array(toRoot)
    }
  }
  
  
  private var addressString : String {
    let oid = UInt(bitPattern: ObjectIdentifier(viewController))
    return "0x" + String(oid, radix: 16)
  }
  
  private var title : String {
    if viewController is AnyViewController {
      return "AnyVC: " + addressString
    }
    else {
      return String(describing: type(of: viewController))
    }
  }
  
  var body: some View {
    if let avc = viewController as? AnyViewController {
      VStack(alignment: .leading) {
        Label(title, systemImage: "envelope")
          .padding()
        
        Divider()
        
        ViewControllerInfo(watchChanges: avc,
                           viewController: avc.viewController)
      }
    }
    else {
      VStack(alignment: .leading) {
        Label(title, systemImage: "ladybug")
          .padding()
        
        Divider()
        
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            TitledField(label: "Description", value: viewController)
            
            if let vc = viewController.parent {
              TitledField(label: "Parent", value: vc) // TBD: recurse?
            }

            if let vc = viewController.presentedViewController {
              TitledField(label: "Presenting other", value: vc)
            }
            
            if let vc = viewController.presentingViewController {
              TitledField(label: "Presented by", value: vc)
            }
            else {
              if viewController.parent == nil { Text("Root") }
              else { Text("Contained") }
            }
          }
          .padding()
          
          HierarchyView(title: "Parent Hierarchy",
                        controllers: parentHierarchy)
          HierarchyView(title: "Presentation Hierarchy",
                        controllers: presentationHierarchy)
          
          Spacer()
        }
      }
    }
  }
}

#endif // DEBUG
