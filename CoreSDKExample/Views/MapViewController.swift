import Combine
import CoreLocation
import Foundation
import MapboxMaps
import MapboxNavigationCore
import UIKit
import HDAugmentedReality
import MapKit

final class MapViewController: UIViewController, NavigationMapViewDelegate, ARDataSource, UISearchResultsUpdating, MKLocalSearchCompleterDelegate {
    private static let styleUrl = "mapbox://styles/alikhaled/cm1ec0kwn02x201q133th82p5"
    private let navigation: Navigation
    private let customLocationManager = CustomLocationManager() // Initialize CustomLocationManager
    private let navigationMapView: NavigationMapView
    private var lifetimeSubscriptions: Set<AnyCancellable> = []
    private var showFavorites = false

    // Favorite locations
    private let favoriteLocationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Favorites", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var favoritePlaces: [Location] = [
        Location(title: "Computer Science", lat: 33.882332, lon: -117.882660, altitude: 0.0, type: .computerScience),
        Location(title: "Computer Science 1", lat: 33.882332, lon: -117.882660, altitude: 10.0, type: .computerScience),
        Location(title: "Computer Science 2", lat: 33.882332, lon: -117.882660, altitude: 20.0, type: .computerScience),
        Location(title: "Computer Science 3", lat: 33.882332, lon: -117.882660, altitude: 30.0, type: .computerScience),
        Location(title: "Engineering", lat: 33.882310, lon: -117.883218, altitude: 0.0, type: .engineering),
        Location(title: "College Park", lat: 33.877629, lon: -117.8835604, altitude: 0.0, type: .park),
        Location(title: "Education-Classroom (EC)", lat: 33.881262, lon: -117.884343, altitude: 0.0, type: .education),
        Location(title: "Humanities", lat: 33.8804109, lon: -117.8844548, altitude: 0.0, type: .humanities),
        Location(title: "McCarthy Hall", lat: 33.8796612, lon: -117.8862273, altitude: 0.0, type: .mccarthyHall),
        Location(title: "Dan Black Hall", lat: 33.8791919, lon: -117.8860329, altitude: 0.0, type: .danBlackHall),
        Location(title: "Health Center", lat: 33.883011, lon: -117.884225, altitude: 0.0, type: .healthCenter),
        Location(title: "Titan Gym", lat: 33.883082, lon: -117.887582, altitude: 0.0, type: .gymnasium),
        Location(title: "Titan Student Union", lat: 33.881350, lon: -117.887668, altitude: 0.0, type: .studentUnion),
        Location(title: "Kinesiology and Health Science", lat: 33.882819, lon: -117.885430, altitude: 0.0, type: .kinesiology),
        Location(title: "Clayes Performing Arts Center", lat: 33.880463, lon: -117.886648, altitude: 0.0, type: .performingArts),
        Location(title: "Titan Recreation Center", lat: 33.882973, lon: -117.887792, altitude: 0.0, type: .gymnasium),
        Location(title: "Titan Shop", lat: 33.881920, lon: -117.886820, altitude: 0.0, type: .library),
        Location(title: "Nutwood Parking Structure", lat: 33.8792741, lon: -117.8887994, altitude: 0.0, type: .parkingLot),
        Location(title: "Titan Hall", lat: 33.880846, lon: -117.890127, altitude: 0.0, type: .universityHall),
        Location(title: "CSUF Police", lat: 33.883140, lon: -117.889384, altitude: 0.0, type: .universityHall),
        Location(title: "Pollak Library", lat: 33.88148526699614, lon: -117.88539035273149, altitude: 0.0, type: .library),
        Location(title: "Visual Arts", lat: 33.880352, lon: -117.888445, altitude: 0.0, type: .visualArts),
        Location(title: "Financial Aid Office", lat: 33.879757, lon: -117.884189, altitude: 0.0, type: .financialAidOffice),
        Location(title: "Langsdorf Hall", lat: 33.878932, lon: -117.884650, altitude: 0.0, type: .langsdorfHall),
        Location(title: "Steven G. Mihaylo Hall", lat: 33.878633, lon: -117.883338, altitude: 0.0, type: .mihayloHall),
        Location(title: "CSUF Housing", lat: 33.883649, lon: -117.881816, altitude: 0.0, type: .dormitory),
        Location(title: "Ruby Gerontology Center", lat: 33.883641, lon: -117.883249, altitude: 0.0, type: .rubyCenter),
        Location(title: "Titan Dining", lat: 33.883119, lon: -117.882486, altitude: 0.0, type: .cafeteria),
        Location(title: "Titan House", lat: 33.884164, lon: -117.884137, altitude: 0.0, type: .dormitory),
        Location(title: "Anderson Family Field", lat: 33.885952, lon: -117.885010, altitude: 0.0, type: .dormitory),
        Location(title: "Goodwin Field", lat: 33.887029, lon: -117.885451, altitude: 0.0, type: .dormitory),
        Location(title: "Titan Stadium", lat: 33.886743, lon: -117.887002, altitude: 0.0, type: .gymnasium)

        // Add more locations here
    ]
    private var favoritesOverlay: UIView?

    // Search-related properties
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private var searchController: UISearchController!

    // Callbacks for SwiftUI to trigger actions
    var onSearchCompletionSelected: ((MKLocalSearchCompletion) -> Void)?
    var onNavigationStart: (() -> Void)?
    var onNavigationClear: (() -> Void)?

    // AR navigation button
    private let startARButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start AR Nav", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(navigation: Navigation) {
        self.navigation = navigation
        self.navigationMapView = NavigationMapView(
            location: navigation.$currentLocation.compactMap { $0 }.eraseToAnyPublisher(),
            routeProgress: navigation.$routeProgress.eraseToAnyPublisher(),
            predictiveCacheManager: navigation.predictiveCacheManager
        )

        navigationMapView.viewportPadding = UIEdgeInsets(top: 20, left: 20, bottom: 80, right: 20)
        super.init(nibName: nil, bundle: nil)

       // customLocationManager.$nodes
           // .sink { [weak self] nodes in
              //  self?.updateNodeDistances(nodes)
            //}
            //.store(in: &lifetimeSubscriptions)

        setupMapView()
        observePreviewRoute()
        observeCamera()
    }

//    private func updateNodeDistances(_ nodes: [Node]) {
//        for node in nodes {
//            print("\(node.title) is \(node.distance) meters away")
//        }
//        // Update AR annotations based on distances if needed
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            navigation.cameraState = .following
            navigation.startFreeDrive()
        }

        setupButtons()
        setupSearchController()
    }

    override func loadView() {
        view = navigationMapView
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupMapView() {
        navigationMapView.mapView.mapboxMap.loadStyle(StyleURI(rawValue: Self.styleUrl)!)
        navigationMapView.mapView.ornaments.compassView.isHidden = true
        navigationMapView.delegate = self
        navigationMapView.showsTrafficOnRouteLine = true
    }

    private func setupButtons() {
        view.addSubview(startARButton)
        NSLayoutConstraint.activate([
            startARButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -299),  // Align to the right
            startARButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 115),  // Align near the top
            startARButton.widthAnchor.constraint(equalToConstant: 100),  // Adjust width as needed
            startARButton.heightAnchor.constraint(equalToConstant: 100)  // Adjust height as needed
        ])
        
        startARButton.addTarget(self, action: #selector(startARNavigation), for: .touchUpInside)
    }

    @objc private func toggleFavoriteLocations() {
        showFavorites.toggle()
        
        if showFavorites {
            showFavoriteLocationsOverlay()
        } else {
            removeFavoriteLocationsOverlay()
        }
    }

    @objc private func selectLocation(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let selectedPlace = favoritePlaces[label.tag]
            zoomToFavoriteLocation(selectedPlace)
        }
    }

    private func zoomToFavoriteLocation(_ place: Location) {
        let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
        navigationMapView.mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: 15.0), duration: 1.0)
    }

    private func removeFavoriteLocationsOverlay() {
        favoritesOverlay?.removeFromSuperview()
        favoritesOverlay = nil
    }

    private func showFavoriteLocationsOverlay() {
        favoritesOverlay = UIView()
        favoritesOverlay?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        favoritesOverlay?.translatesAutoresizingMaskIntoConstraints = false

        if let favoritesOverlay = favoritesOverlay {
            view.addSubview(favoritesOverlay)

            NSLayoutConstraint.activate([
                favoritesOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
                favoritesOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                favoritesOverlay.topAnchor.constraint(equalTo: favoriteLocationsButton.bottomAnchor, constant: 50),
                favoritesOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            favoritesOverlay.addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: favoritesOverlay.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: favoritesOverlay.trailingAnchor, constant: -16),
                stackView.topAnchor.constraint(equalTo: favoritesOverlay.topAnchor, constant: 40)
            ])

            for place in favoritePlaces {
                let label = UILabel()
                label.text = place.title
                label.textColor = .orange
                label.backgroundColor = UIColor.orange.withAlphaComponent(0.85)
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                label.textAlignment = .center
                label.isUserInteractionEnabled = true

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFavoriteLocation(_:)))
                label.addGestureRecognizer(tapGesture)
                label.tag = favoritePlaces.firstIndex(of: place) ?? 0

                stackView.addArrangedSubview(label)
            }
        }
    }

    @objc private func selectFavoriteLocation(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let selectedPlace = favoritePlaces[label.tag]
            print("Selected favorite location: \(selectedPlace.title)")
            startNavigationToFavorite(selectedPlace)
        }
    }

    private func startNavigationToFavorite(_ location: Location) {
        let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        print("Selected favorite location: \(location.title), Coordinate: \(coordinate)")
        // Continue with the rest of the logic...
        Task {
            do {
                let mapPoint = MapPoint(name: location.title, coordinate: coordinate)
                print("Requesting route to \(mapPoint.name ?? "unknown"), Coordinate: \(mapPoint.coordinate)")
                try await navigation.requestRoutes(to: mapPoint)

                if let previewRoutes = navigation.currentPreviewRoutes {
                    print("Routes preview available. Displaying routes on the map.")
                    let routeAnnotationKinds: Set<RouteAnnotationKind> = [.routeDurations]
                    navigationMapView.show(previewRoutes, routeAnnotationKinds: routeAnnotationKinds)
                } else {
                    print("No routes available to display.")
                }
            } catch {
                print("Error requesting route: \(error.localizedDescription)")
            }
        }
    }




    private func setupSearchController() {
        searchCompleter.delegate = self
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }

    func performSearch(for result: MKLocalSearchCompletion) {
        onSearchCompletionSelected?(result)
    }

    @objc private func startARNavigation() {
        showARViewController()
    }

    private func showARViewController() {
        let arViewController = ARViewController()
        let presenter = arViewController.presenter!
        
        presenter.distanceOffsetMode = .manual
        presenter.distanceOffsetMultiplier = 0.05
        presenter.distanceOffsetMinThreshold = 1000
        presenter.maxDistance = 5000
        presenter.maxVisibleAnnotations = 100
        presenter.presenterTransform = ARPresenterStackTransform()
        
        let trackingManager = arViewController.trackingManager
        trackingManager.userDistanceFilter = 15
        trackingManager.reloadDistanceFilter = 50
        
        arViewController.uiOptions.debugLabel = false
        arViewController.uiOptions.debugMap = true
        arViewController.uiOptions.simulatorDebugging = Platform.isSimulator
        arViewController.uiOptions.setUserLocationToCenterOfAnnotations = Platform.isSimulator
        arViewController.interfaceOrientationMask = .all
        arViewController.modalPresentationStyle = .fullScreen
        
        let radarView = RadarMapView()
        radarView.startMode = .centerUser(span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        radarView.trackingMode = .none
        radarView.indicatorRingType = .segmented(segmentColor: nil, userSegmentColor: nil)
        
        arViewController.addAccessory(radarView, leading: 15, trailing: nil, top: nil, bottom: 15, width: 150, height: 150)
        
        arViewController.dataSource = self
        arViewController.setAnnotations(MapViewController.getDummyAnnotations())
        
        self.present(arViewController, animated: true, completion: nil)
    }

    private func observePreviewRoute() {
        navigation.$currentPreviewRoutes
            .removeDuplicates()
            .combineLatest(navigation.$activeNavigationRoutes)
            .sink { [weak self] previewRoutes, routes in
                guard let self = self else { return }
                if let previewRoutes {
                    self.navigationMapView.showcase(previewRoutes, routeAnnotationKinds: [.routeDurations], animated: true)
                } else if let routes {
                    self.navigationMapView.show(routes, routeAnnotationKinds: [.relativeDurationsOnAlternativeManuever])
                } else {
                    self.navigationMapView.removeRoutes()
                }
            }
            .store(in: &lifetimeSubscriptions)
    }


    func observeCamera() {
        navigation.$cameraState
            .removeDuplicates()
            .sink { [weak self] cameraState in
                self?.navigationMapView.update(navigationCameraState: cameraState)
            }
            .store(in: &lifetimeSubscriptions)
    }

    private func requestRoute(to mapPoint: MapPoint) async {
        do {
            print("Starting request for route to: \(mapPoint.name ?? "unknown location") at \(mapPoint.coordinate)")
            try await navigation.requestRoutes(to: mapPoint)
            print("Route successfully requested to \(mapPoint.name ?? "unknown location")")
            
            if let previewRoutes = navigation.currentPreviewRoutes {
                print("Routes preview available. Displaying routes on the map.")
                let routeAnnotationKinds: Set<RouteAnnotationKind> = [.routeDurations]
                navigationMapView.show(previewRoutes, routeAnnotationKinds: routeAnnotationKinds)
            } else {
                print("No routes available to display.")
            }

        } catch {
            print("Error during route request: \(error.localizedDescription)")
            presentAlert(message: "Request failed: \(error.localizedDescription)")
        }
    }

    private func presentAlert(_ title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer failed with error: \(error)")
    }

    func navigationMapView(_ navigationMapView: NavigationMapView, userDidTap mapPoint: MapPoint) {
        Task { await requestRoute(to: mapPoint) }
    }

    func navigationMapView(_ navigationMapView: NavigationMapView, userDidLongTap mapPoint: MapPoint) {
        Task { await requestRoute(to: mapPoint) }
    }

    func ar(_ arViewController: ARViewController, viewForAnnotation annotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = TestAnnotationView()
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        return annotationView
    }

    func ar(_ arViewController: ARViewController, didFailWithError error: Error) {
        if let _ = error as? CameraViewError {
            let alert = UIAlertController(title: "Error", message: "Failed to initialize camera.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Close", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    public class func getDummyAnnotations() -> [ARAnnotation] {
        var annotations: [ARAnnotation] = []
        let locations = [
      
            
           
            
             (title: "Computer Science", lat: 33.882332, lon: -117.882660, altitude: 0.0, type: TestAnnotationType.computerScience),
             // New Computer Science duplicates
             
             
             (title: "Computer Science 1", lat: 33.882332, lon: -117.882660, altitude: 10.0, type: TestAnnotationType.computerScience),
             (title: "Computer Science 2", lat: 33.882332, lon: -117.882660, altitude: 20.0, type: TestAnnotationType.computerScience),
             (title: "Computer Science 3", lat: 33.882332, lon: -117.882660, altitude: 30.0, type: TestAnnotationType.computerScience),
             (title: "Engineering", lat: 33.882310, lon: -117.883218, altitude: 0.0, type: TestAnnotationType.engineering),
             // wrong location (title: "Parking Lot (PL)", lat: 33.880319, lon: -117.887015, altitude: 0.0, type: TestAnnotationType.parkingLot),
             (title: "College Park", lat:  33.877629, lon: -117.8835604, altitude: 0.0, type: TestAnnotationType.park),
             
             (title: "Education-Classroom (EC)", lat: 33.881262, lon: -117.884343, altitude: 0.0, type: TestAnnotationType.education),
             //NEW and Fixed
             (title: "Humanities", lat: 33.8804109, lon: -117.8844548, altitude: 0.0, type: TestAnnotationType.humanities),

             (title: "McCarthy Hall", lat: 33.8796612, lon: -117.8862273, altitude: 0.0, type: TestAnnotationType.mccarthyHall),
             
             (title: "Dan Black Hall", lat: 33.8791919, lon: -117.8860329, altitude: 0.0, type: TestAnnotationType.danBlackHall),
             (title: "Health Center", lat: 33.883011, lon: -117.884225, altitude: 0.0, type: TestAnnotationType.healthCenter),
             (title: "Titan Gym", lat: 33.883082, lon: -117.887582, altitude: 0.0, type: TestAnnotationType.gymnasium),
             (title: "Titan Student Union", lat: 33.881350, lon: -117.887668, altitude: 0.0, type: TestAnnotationType.studentUnion),
             (title: "Kinesiology and Health Science", lat: 33.882819, lon: -117.885430, altitude: 0.0, type: TestAnnotationType.kinesiology),
             
             (title: "Clayes Performing Arts Center", lat: 33.880463, lon: -117.886648, altitude: 0.0, type: TestAnnotationType.performingArts),
             
             (title: "Titan Recreation Center", lat:  33.882973, lon: -117.887792, altitude: 0.0, type: TestAnnotationType.gymnasium),
             (title: "Titan Shop", lat: 33.881920, lon: -117.886820, altitude: 0.0, type: TestAnnotationType.library),
             
             (title: "Nutwood Parking Structure", lat: 33.8792741, lon: -117.8887994, altitude: 0.0, type: TestAnnotationType.parkingLot),
            
             //Fixed
             //(title: "Student Business Services", lat: 33.8762574, lon: -117.8837534, altitude: 0.0, type: TestAnnotationType.admissionsOffice),

             (title: "Titan Hall", lat: 33.880846, lon: -117.890127, altitude: 0.0, type: TestAnnotationType.universityHall),
             (title: "CSUF Police", lat: 33.883140, lon: -117.889384, altitude: 0.0, type: TestAnnotationType.universityHall),
             
             (title: "Pollak Library", lat: 33.88148526699614, lon:  -117.88539035273149, altitude: 0.0, type: TestAnnotationType.library),

             (title: "Visual Arts", lat: 33.880352, lon: -117.888445, altitude: 0.0, type: TestAnnotationType.visualArts),
             
             (title: "Financial Aid Office", lat: 33.879757, lon: -117.884189, altitude: 0.0, type: TestAnnotationType.financialAidOffice),
             
             (title: "Langsdorf Hall", lat: 33.878932, lon: -117.884650, altitude: 0.0, type: TestAnnotationType.langsdorfHall),
             
             (title: "Steven G. Mihaylo Hall", lat: 33.878633, lon: -117.883338, altitude: 0.0, type: TestAnnotationType.mihayloHall),

             (title: "CSUF Housing", lat: 33.883649, lon: -117.881816, altitude: 0.0, type: TestAnnotationType.dormitory),

             (title: "Ruby Gerontology Center", lat: 33.883641, lon: -117.883249, altitude: 0.0, type: TestAnnotationType.rubyCenter),
             (title: "Titan Dining", lat: 33.883119, lon: -117.882486, altitude: 0.0, type: TestAnnotationType.cafeteria),
             
             (title: "Titan House", lat: 33.884164, lon: -117.884137, altitude: 0.0, type: TestAnnotationType.dormitory),
             
             (title: "Anderson Family Field", lat:  33.885952, lon: -117.885010, altitude: 0.0, type: TestAnnotationType.dormitory),
             
             (title: "Goodwin Field", lat: 33.887029, lon: -117.885451, altitude: 0.0, type: TestAnnotationType.dormitory),
             
             (title: "Titan Stadium", lat:  33.886743, lon: -117.887002, altitude: 0.0, type: TestAnnotationType.gymnasium)


        ]
        
        for location in locations {
            let locationObject = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon),
                altitude: location.altitude,
                horizontalAccuracy: 1,
                verticalAccuracy: 1,
                course: 0,
                speed: 0,
                timestamp: Date()
            )
            if let annotation = TestAnnotation(
                identifier: nil,
                title: location.title,
                location: locationObject,
                type: location.type
            ) {
                annotations.append(annotation)
            }
        }
        return annotations
    }
}





