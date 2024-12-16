//import UIKit
//import CoreLocation
//import HDAugmentedReality
//import MapKit
//
//class ViewController: UIViewController {
//    
//    // Create a button programmatically
//    let startButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Start AR Navigation", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = UIColor.systemBlue
//        button.layer.cornerRadius = 25
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOpacity = 0.3
//        button.layer.shadowOffset = CGSize(width: 0, height: 3)
//        button.layer.shadowRadius = 6
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Set up the UI
//        setupUI()
//    }
//    
//    func setupUI() {
//        // Set background color
//        view.backgroundColor = .white
//        
//        // Add the start button to the view
//        view.addSubview(startButton)
//        
//        // Set button constraints
//        NSLayoutConstraint.activate([
//            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            startButton.widthAnchor.constraint(equalToConstant: 200),
//            startButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//        
//        // Add target to the button
//        startButton.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
//    }
//    
//    @objc func buttonTap(_ sender: AnyObject) {
//        // Call the method to present ARViewController
//        self.showARViewController()
//    }
//    
//    // ARViewController setup and display
//    func showARViewController() {
//        // Create random annotations around center point
//        _ = 33.88230547341042
//        _ = -117.88465074266475
//        let dummyAnnotations = ViewController.getDummyAnnotations()
//        
//        // ARViewController setup
//        let arViewController = ARViewController()
//        
//        // Presenter setup
//        let presenter = arViewController.presenter!
//        presenter.distanceOffsetMode = .manual
//        presenter.distanceOffsetMultiplier = 0.05
//        presenter.distanceOffsetMinThreshold = 1000
//        presenter.maxDistance = 5000
//        presenter.maxVisibleAnnotations = 100
//        presenter.presenterTransform = ARPresenterStackTransform()
//
//        // Tracking manager setup
//        let trackingManager = arViewController.trackingManager
//        trackingManager.userDistanceFilter = 15
//        trackingManager.reloadDistanceFilter = 50
//        
//        // ARViewController options
//        arViewController.dataSource = self
//        arViewController.uiOptions.debugLabel = false
//        arViewController.uiOptions.debugMap = true
//        arViewController.uiOptions.simulatorDebugging = Platform.isSimulator
//        arViewController.uiOptions.setUserLocationToCenterOfAnnotations = Platform.isSimulator
//        arViewController.interfaceOrientationMask = .all
//        arViewController.onDidFailToFindLocation = { [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
//            self?.handleLocationFailure(elapsedSeconds: elapsedSeconds, acquiredLocationBefore: acquiredLocationBefore, arViewController: arViewController)
//        }
//        
//        // Set annotations
//        arViewController.setAnnotations(dummyAnnotations)
//        arViewController.modalPresentationStyle = .fullScreen
//        
//        // Radar setup
//        var safeArea = UIEdgeInsets.zero
//        if #available(iOS 11.0, *) {
//            safeArea = UIApplication.shared.delegate?.window??.safeAreaInsets ?? UIEdgeInsets.zero
//        }
//        
//        let radar = RadarMapView()
//        radar.startMode = .centerUser(span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        radar.trackingMode = .none
//        radar.indicatorRingType = .segmented(segmentColor: nil, userSegmentColor: nil)
//        arViewController.addAccessory(radar, leading: 15, trailing: nil, top: nil, bottom: 15 + safeArea.bottom / 4, width: nil, height: 150)
//        
//        // Present ARViewController
//        self.present(arViewController, animated: true, completion: nil)
//    }
//    
//    // Handle location failure
//    func handleLocationFailure(elapsedSeconds: TimeInterval, acquiredLocationBefore: Bool, arViewController: ARViewController?) {
//        guard let arViewController = arViewController else { return }
//        guard !Platform.isSimulator else { return }
//        NSLog("Failed to find location after: \(elapsedSeconds) seconds, acquiredLocationBefore: \(acquiredLocationBefore)")
//        
//        if elapsedSeconds >= 20 && !acquiredLocationBefore {
//            arViewController.trackingManager.stopTracking()
//            let alert = UIAlertController(title: "Problems", message: "Cannot find location, use Wi-Fi if possible!", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Close", style: .cancel) { (action) in
//                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//}
//
//// MARK: - ARDataSource
//extension ViewController: ARDataSource {
//    func ar(_ arViewController: ARViewController, viewForAnnotation annotation: ARAnnotation) -> ARAnnotationView {
//        let annotationView = TestAnnotationView()
//        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
//        return annotationView
//    }
//    
//    func ar(_ arViewController: ARViewController, didFailWithError error: Error) {
//        if let _ = error as? CameraViewError {
//            let alert = UIAlertController(title: "Error", message: "Failed to initialize camera.", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Close", style: .cancel) { (action) in
//                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//}
//extension ViewController {
//    public class func getDummyAnnotations() -> [ARAnnotation] {
//        var annotations: [ARAnnotation] = []
//        let locations = [
//            (title: "Library", lat: 33.877912, lon: -117.886295, type: TestAnnotationType.library),
//            (title: "Performing Arts Center", lat: 33.879249, lon: -117.889689, type: TestAnnotationType.performingArts),
//            (title: "Computer Science", lat: 33.882395, lon: -117.882724, type: TestAnnotationType.computerScience),
//            (title: "Engineering", lat: 33.882305, lon: -117.883239, type: TestAnnotationType.engineering),
//            (title: "University Hall", lat: 33.879651, lon: -117.884301, type: TestAnnotationType.universityHall),
//            // New locations
//            (title: "Collage Park", lat: 33.877912, lon: -117.886295, type: TestAnnotationType.park),
//            (title: "Education-Classroom", lat: 33.881262, lon: -117.884343, type: TestAnnotationType.education),
//            (title: "Humanities", lat: 33.880444, lon: -117.884167, type: TestAnnotationType.humanities),
//            (title: "Kinesiology and Health Science", lat: 33.883076, lon: -117.885807, type: TestAnnotationType.kinesiology),
//            (title: "Langsdorf Hall", lat: 33.878984, lon: -117.884435, type: TestAnnotationType.langsdorfHall),
//            (title: "McCarthy Hall", lat: 33.880030, lon: -117.886533, type: TestAnnotationType.mccarthyHall),
//            (title: "Dan Black Hall", lat: 33.879194, lon: -117.885833, type: TestAnnotationType.danBlackHall),
//            (title: "Ruby Gerontology Center", lat: 33.883639, lon: -117.883289, type: TestAnnotationType.rubyCenter),
//            (title: "Steven G. Mihaylo Hall", lat: 33.878857, lon: -117.883295, type: TestAnnotationType.mihayloHall),
//            (title: "Visual Arts", lat: 33.879201, lon: -117.888866, type: TestAnnotationType.visualArts),
//            (title: "Student Union (SU)", lat: 33.881063, lon: -117.888452, type: TestAnnotationType.studentUnion),
//            (title: "Parking Lot (PL)", lat: 33.880319, lon: -117.887015, type: TestAnnotationType.parkingLot)
//        ]
//        
//        for location in locations {
//            let locationObject = CLLocation(coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon), altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, course: 0, speed: 0, timestamp: Date())
//            if let annotation = TestAnnotation(identifier: nil, title: location.title, location: locationObject, type: location.type) {
//                annotations.append(annotation)
//            }
//        }
//        return annotations
//    }
//}
