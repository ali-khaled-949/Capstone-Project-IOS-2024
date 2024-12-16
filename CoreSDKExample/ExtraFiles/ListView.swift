////
////  ListView.swift
////  Titan Routes
////
////  Created by Ali Main on 9/22/24.
////
//
//import Foundation
//import SwiftUI
//
//struct ListTabView: View {
//    let items = ["One", "Two", "Three", "Computer Science"] // Add the property name from the JSON data
//
//    var body: some View {
//        NavigationView {
//            List(items, id: \.self) { item in
//                Button(action: {
//                    handleItemClick(item: item)
//                }) {
//                    Text(item)
//                        .font(.title2)
//                        .padding()
//                        .foregroundColor(item == "Computer Science" ? .blue : .black) // Highlight the matching item
//                        .overlay(alignment: .trailing) {
//                            if item == "Computer Science" {
//                                Image(systemName: "star.fill")
//                                    .foregroundColor(.yellow)
//                                    .padding(.trailing, 4)
//                            }
//                        }
//                }
//            }
//            .navigationTitle("Selectable List")
//        }
//    }
//
//    func handleItemClick(item: String) {
//        print("Selected: \(item)")
//    }
//}
