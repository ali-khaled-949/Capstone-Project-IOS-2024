import CoreLocation
import Combine

struct Node {
    let title: String
    let location: CLLocation
    var distance: CLLocationDistance = 0.0 // Distance from user, updates dynamically
}

final class CustomLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var nodes: [Node] = [
        Node(title: "Library", location: CLLocation(latitude: 33.877912, longitude: -117.886295)),
        Node(title: "Performing Arts Center", location: CLLocation(latitude: 33.879249, longitude: -117.889689)),
        Node(title: "Computer Science", location: CLLocation(latitude: 33.882395, longitude: -117.882724)),
        Node(title: "Engineering", location: CLLocation(latitude: 33.882305, longitude: -117.883239)),
        Node(title: "University Hall", location: CLLocation(latitude: 33.879651, longitude: -117.884301)),
        Node(title: "Collage Park", location: CLLocation(latitude: 33.877912, longitude: -117.886295)),
        Node(title: "Education-Classroom", location: CLLocation(latitude: 33.881262, longitude: -117.884343)),
        Node(title: "Humanities", location: CLLocation(latitude: 33.880444, longitude: -117.884167)),
        Node(title: "Kinesiology and Health Science", location: CLLocation(latitude: 33.883076, longitude: -117.885807))
    ]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location

        // Update distance for each node from the user's current location
        for index in nodes.indices {
            nodes[index].distance = location.distance(from: nodes[index].location)
          //  print("Distance to \(nodes[index].title): \(nodes[index].distance) meters") // Debug log
        }
    }
}
