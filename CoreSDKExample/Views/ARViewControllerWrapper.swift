import SwiftUI
import UIKit
import FirebaseAuth
import HealthKit
import HDAugmentedReality

// MARK: - ARViewControllerWrapper for AR Integration
struct ARViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARViewController {
        let arVC = ARViewController()
        arVC.dataSource = context.coordinator
        return arVC
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARDataSource {
        var parent: ARViewControllerWrapper

        init(_ parent: ARViewControllerWrapper) {
            self.parent = parent
        }

        func ar(_ arViewController: ARViewController, viewForAnnotation annotation: ARAnnotation) -> ARAnnotationView {
            let annotationView = TestAnnotationView()
            annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
            return annotationView
        }
    }
}
//
//
//import SwiftUI
//import UIKit
//
//// Wrapper to integrate UIKit ViewController into SwiftUI
//struct ViewControllerWrapper: UIViewControllerRepresentable {
//    
//    // This method creates the UIKit ViewController
//    func makeUIViewController(context: Context) -> ViewController {
//        return ViewController() // Replace this with your ViewController init logic if needed
//    }
//
//    // This method updates the ViewController when SwiftUI state changes
//    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
//        // Update ViewController if needed
//    }
//}
