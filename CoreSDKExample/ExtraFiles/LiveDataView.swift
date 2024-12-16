//import SwiftUI
//import CoreLocation
//import MapboxNavigationCore
//
//struct LiveDataView: View {
//    @ObservedObject var locationManager = LocationManager()
//    @ObservedObject var navigation: Navigation  // Inject the navigation object
//    @State private var showInfoBox = true  // Toggle for info box visibility
//
//    var body: some View {
//        ZStack {
//            // Toggle Button to Show/Hide Info Box
//            VStack {
//                HStack {
//                    Spacer()
//                   // Button(action: {
//                     //   withAnimation {
//                       //     showInfoBox.toggle()  // Toggle visibility of the info box
//                    //    }
//                 //   })// {
//                       // Text(showInfoBox ? "Hide Info" : "Show Info")
//                       //     .font(.system(size: 14))
//                       //     .padding(8)
//                        //     .background(Color.blue)
//                        //    .foregroundColor(.white)
//                      //      .cornerRadius(8)
//                   // }
//                    .padding(.top, 50)
//                    .padding(.trailing, 20)
//                }
//                Spacer()  // Push button to the top-right
//            }
//            
//            // Settings Gear Icon
//            SettingsControlsView(navigation: navigation)  // Embed the gear icon here
//            
//            // The Info Box (Elevation, Speed, Heading)
//         //   if showInfoBox {
//               // VStack(alignment: .leading, spacing: 5) {
//                  //  Text("Elevation: \(locationManager.elevation, specifier: "%.2f") meters")
//                  //  Text("Speed: \(locationManager.speed >= 0 ? locationManager.speed : 0, specifier: "%.2f") m/s")  // Handle negative speeds
//               //     Text("Heading: \(locationManager.heading, specifier: "%.2f")°")
//              //  }
//               // .padding()
//             //   .background(Color.white.opacity(0.8))
//            //    .cornerRadius(10)
//            //    .shadow(radius: 5)
//            //    .frame(width: 150)  // Fixed width for the info box
//            //    .padding(.top, 500)
//            //    .padding(.trailing, 20)
//            //    .transition(.move(edge: .trailing))  // Smooth transition for visibility
//           // }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)  // Ensure full screen usage
//    }
//}
//
//// LocationManager remains unchanged
//
//
//// Corrected LocationManager class for CLLocation updates
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let manager = CLLocationManager()
//
//    // Published properties for live data
//    @Published var userLocation: CLLocationCoordinate2D?
//    @Published var elevation: Double = 0.0
//    @Published var speed: Double = 0.0
//    @Published var heading: Double = 0.0
//
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.requestWhenInUseAuthorization() // Request permission
//        manager.startUpdatingLocation() // Start getting location updates
//        manager.startUpdatingHeading() // Start getting heading updates
//    }
//
//    // Update location data
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        self.userLocation = location.coordinate
//        self.elevation = location.altitude
//        self.speed = max(location.speed, 0)  // Ensure speed is non-negative
//    }
//
//    // Update heading data
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        self.heading = newHeading.trueHeading
//    }
//
//    // Handle permission changes
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedWhenInUse, .authorizedAlways:
//            manager.startUpdatingLocation()
//        case .denied, .restricted:
//            print("Location services denied or restricted")
//        default:
//            break
//        }
//    }
//}
//
//
//
//struct SettingsControlsView: View {
//    @ObservedObject var navigation: Navigation
//    @State private var settingsVisible = false
//
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                settingsButton
//            }
//            Spacer()
//        }
//        .sheet(isPresented: $settingsVisible) {
//            SettingsView(navigation: navigation)
//        }
//    }
//
//    private var settingsButton: some View {
//        Button(action: { settingsVisible.toggle() }) {
//            Image(systemName: "gear")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.blue)
//                .frame(width: 30, height: 30)
//                .padding()
//                .background(Color(.systemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//                .shadow(radius: 3)
//        }
//        .padding()
//    }
//}
//
//extension ProfileIdentifier {
//    var displayName: String {
//        switch self {
//        case .walking:
//            return "Walking"
//        case .automobile:
//            return "Driving"
//    //    case .automobileAvoidingTraffic:
//    //        return "Driving with Traffic"
//        case .cycling:
//            return "Cycling"
//       
//        default:
//            return "Unknown"
//        }
//    }
//}
