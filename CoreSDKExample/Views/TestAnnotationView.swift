import UIKit
import HDAugmentedReality
import CoreLocation

open class TestAnnotationView: ARAnnotationView, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    open var backgroundImageView: UIImageView?
    open var gradientImageView: UIImageView?
    open var iconImageView: UIImageView?
    open var titleLabel: UILabel?
    open var arFrame: CGRect = .zero  // Just for test stacking
    
    private let locationManager = CLLocationManager() // Location manager for tracking user location
    
    override open weak var annotation: ARAnnotation? {
        didSet { self.bindAnnotation() }
    }

    override open func initialize() {
        super.initialize()
        setupUI()
        setupLocationManager()
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.superview != nil ? startRotating() : stopRotating()
    }

    /// Sets up the UI elements programmatically
    private func setupUI() {
        // Background image
        let backgroundImage = UIImage(named: "annotationViewBackground")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 30), resizingMode: .stretch)
        backgroundImageView = UIImageView(image: backgroundImage)
        addSubview(backgroundImageView!)

        // Gradient overlay image
        let gradientImage = UIImage(named: "annotationViewGradient")?.withRenderingMode(.alwaysTemplate)
        gradientImageView = UIImageView(image: gradientImage)
        gradientImageView?.contentMode = .scaleAspectFit
        addSubview(gradientImageView!)

        // Icon image
        iconImageView = UIImageView()
        iconImageView?.contentMode = .scaleAspectFit
        addSubview(iconImageView!)

        // Title label
        titleLabel = UILabel()
        titleLabel?.font = UIFont.systemFont(ofSize: 10)
        titleLabel?.numberOfLines = 0
        titleLabel?.textColor = .white
        titleLabel?.backgroundColor = .clear
        addSubview(titleLabel!)

        // Tap gesture for annotation view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        self.addGestureRecognizer(tapGesture)
        
        self.backgroundColor = .clear

        if annotation != nil { bindUi() }
    }
    
    /// Sets up the location manager to receive user location updates
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1 // Update every 5 meters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    /// CLLocationManagerDelegate method for location updates
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else { return }
        bindUi() // Update distance on every new location
    }

    /// Binds annotation details like icon and color to the view
    private func bindAnnotation() {
        guard let annotation = self.annotation as? TestAnnotation else { return }
        let type = annotation.type
        iconImageView?.image = type.icon
        iconImageView?.tintColor = type.tintColor
        gradientImageView?.tintColor = type.tintColor
    }

    /// Updates the layout of UI elements based on the view's frame
    private func layoutUI() {
        let height = self.frame.height
        let iconSize: CGFloat = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? 30 : 20
        
        // Position elements
        backgroundImageView?.frame = self.bounds
        iconImageView?.frame.size = CGSize(width: iconSize, height: iconSize)
        iconImageView?.center = CGPoint(x: height / 2, y: height / 2)
        
        gradientImageView?.frame.size = CGSize(width: iconSize * 2, height: iconSize * 2)
        gradientImageView?.center = CGPoint(x: height / 2, y: height / 2)
        gradientImageView?.layer.cornerRadius = gradientImageView?.frame.size.width ?? 0 / 2
        gradientImageView?.layer.masksToBounds = true

        titleLabel?.frame = CGRect(x: iconSize + 38, y: 0, width: self.frame.width - 20, height: self.frame.height)
    }

    /// This method is called whenever distance/azimuth is set, updating the annotation's title and distance.
    override open func bindUi() {
        guard let annotation = self.annotation as? TestAnnotation else { return }

        let annotationTitle = annotation.title ?? "Unknown Location"
        let distanceText: String
        if annotation.distanceFromUser > 1000 {
            distanceText = String(format: "%.1fkm", annotation.distanceFromUser / 1000)
        } else {
            distanceText = String(format: "%.0fm", annotation.distanceFromUser)
        }

        self.titleLabel?.text = "\(annotationTitle)\n\(distanceText)"
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        print("Layout is refreshing")
        layoutUI()
        
        self.bindUi()

    }

    /// Handler for the tap gesture, presenting more details about the annotation
    @objc open func tapGesture() {
        guard let annotation = self.annotation, let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { return }

        // Present details view controller
        let detailViewController = UIViewController()
        detailViewController.view.backgroundColor = .white
        detailViewController.title = annotation.title

        let label = UILabel()
        label.text = "Details about \(annotation.title ?? "this location")"
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 100, width: 300, height: 50)
        detailViewController.view.addSubview(label)

        let navigationController = UINavigationController(rootViewController: detailViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Animation for Rotation

    /// Starts a continuous rotation animation for the gradient layer
    private func startRotating() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = Double.random(in: 1..<3)
        rotateAnimation.repeatCount = Float.infinity
        gradientImageView?.layer.add(rotateAnimation, forKey: nil)
    }
    
    /// Stops the rotation animation
    private func stopRotating() {
        gradientImageView?.layer.removeAllAnimations()
    }
}
