import UIKit
import SwiftUI

class StackTestViewController: UIViewController {
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var generationStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    var generationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var annotationViews: [TestAnnotationView] = []
    private var originalAnnotationViews: [TestAnnotationView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        self.bindUi()
    }

    func setupLayout() {
        self.view.addSubview(scrollView)
        self.view.addSubview(generationStepper)
        self.view.addSubview(generationLabel)
        
        // Add constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: generationStepper.topAnchor, constant: -20),

            generationStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generationStepper.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            generationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generationLabel.bottomAnchor.constraint(equalTo: generationStepper.topAnchor, constant: -10)
        ])
        
        // Load the initial set of UI
        self.loadUi()
    }
    
    func loadUi() {
        // Remove all subviews from scrollView before adding new ones
        for subview in self.scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        // Create new annotation views (originally coming from XIB)
        for _ in 0..<10 {  // You can choose your count
            let annotationView = TestAnnotationView()
            annotationView.frame.size.width = 120
            annotationView.frame.size.height = 40
            annotationView.frame.origin.x = CGFloat(drand48()) * (self.view.frame.width - annotationView.frame.size.width)
            annotationView.frame.origin.y = CGFloat(drand48()) * 300
            annotationViews.append(annotationView)
            scrollView.addSubview(annotationView)
        }
        originalAnnotationViews = annotationViews
    }
    
    func bindUi() {
        self.generationLabel.text = "\(self.generationStepper.value)"
    }
}




struct StackTestViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> StackTestViewController {
        return StackTestViewController()
    }
    
    func updateUIViewController(_ uiViewController: StackTestViewController, context: Context) {
        // Update the view controller as needed
    }
}
