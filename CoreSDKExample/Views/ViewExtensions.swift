//
//  ViewExtensions.swift
//  Titan Routes
//
//  Created by Ali Main on 10/10/24.
//

import Foundation
import SwiftUI

extension View {
    func navigate<Content: View>(to view: Content, when binding: Binding<Bool>) -> some View {
        NavigationLink(destination: view, isActive: binding) {
            EmptyView()
        }
        .hidden()
    }
}
