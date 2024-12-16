////
////  DestinationSearchView.swift
////  Titan Routes
////
////  Created by Ali Main on 9/26/24.
////
//
//import Foundation
//import SwiftUI
//import GooglePlaces
//
//struct DestinationSearchView: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var selectedPlace: GMSPlace?
//
//    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = context.coordinator
//        return autocompleteController
//    }
//
//    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {
//        // No updates needed
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
//        var parent: DestinationSearchView
//
//        init(_ parent: DestinationSearchView) {
//            self.parent = parent
//        }
//
//        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//            parent.selectedPlace = place
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//
//        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//            print("Error: ", error.localizedDescription)
//        }
//
//        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
