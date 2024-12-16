import SwiftUI
import UIKit

struct TestAnnotationViewWrapper: UIViewRepresentable {
    var title: String
    var distance: String
    
    func makeUIView(context: Context) -> TestAnnotationView {
        let annotationView = TestAnnotationView()
        
        // Customize the annotation view
        annotationView.titleLabel?.text = "\(title)\n\(distance)"
        return annotationView
    }

    func updateUIView(_ uiView: TestAnnotationView, context: Context) {
        // Dynamically update the annotation's content if needed
        uiView.titleLabel?.text = "\(title)\n\(distance)"
    }
}
