import Combine
import CoreLocation
import MapboxDirections
import MapboxNavigationCore

@MainActor
final class Navigation: ObservableObject {
    let predictiveCacheManager: PredictiveCacheManager?

    @Published private(set) var isInActiveNavigation: Bool = false
    @Published private(set) var currentPreviewRoutes: NavigationRoutes?
    @Published private(set) var activeNavigationRoutes: NavigationRoutes?
    @Published private(set) var visualInstruction: VisualInstructionBanner?
    @Published private(set) var routeProgress: RouteProgress?
    @Published private(set) var currentLocation: CLLocation?
    @Published var cameraState: NavigationCameraState = .idle
    @Published var profileIdentifier: ProfileIdentifier = .automobileAvoidingTraffic
    @Published var shouldRequestMapMatching = false

    private var waypoints: [Waypoint] = []
    private let core: MapboxNavigation

    init() {
        let config = CoreConfig(
            credentials: .init() // You can pass a custom token if you need to
        )
        let navigationProvider = MapboxNavigationProvider(coreConfig: config)
        self.core = navigationProvider.mapboxNavigation
        self.predictiveCacheManager = navigationProvider.predictiveCacheManager
        observeNavigation()
       
        // Provide custom localization.
        LocalizationManager.customLocalizationBundle = .main
    }

    private func observeNavigation() {
        // Observing the navigation states and updating the UI elements accordingly
        core.tripSession().session
            .map {
                    print("Trip session state: \($0.state)") // Debugging output
                    if case .activeGuidance = $0.state {
                        return true
                    }
                    return false
                }
            .removeDuplicates()
            .assign(to: &$isInActiveNavigation)

        core.navigation().bannerInstructions
            .map { $0.visualInstruction }
            .assign(to: &$visualInstruction)

        core.navigation().routeProgress
            .map { $0?.routeProgress }
            .assign(to: &$routeProgress)

        core.tripSession().navigationRoutes
            .assign(to: &$activeNavigationRoutes)

        core.navigation().locationMatching
            .map { $0.location }
            .assign(to: &$currentLocation)

    }

    func startFreeDrive() {
        // Starts free driving mode (not following a particular route)
        core.tripSession().startFreeDrive()
    }

    func cancelPreview() {
        // Cancels the current route preview
        waypoints = []
        currentPreviewRoutes = nil
        cameraState = .following
    }

    func startActiveNavigation() {
        guard let previewRoutes = currentPreviewRoutes else {
            print("Error: No preview routes available to start navigation")
            return
        }

        // Start active guidance
        core.tripSession().startActiveGuidance(with: previewRoutes, startLegIndex: 0)
        cameraState = .following
        currentPreviewRoutes = nil
        waypoints = []

        print("Navigation started with routes: \(previewRoutes)")
    }


    func stopActiveNavigation() {
        // Stops active navigation and returns to free driving mode
        core.tripSession().startFreeDrive()
        cameraState = .following
    }

    func selectAlternativeRoute(_ alternativeRoute: AlternativeRoute) async {
        // Selects an alternative route, either in preview or active navigation
        if let previewRoutes = currentPreviewRoutes {
            currentPreviewRoutes = await previewRoutes.selecting(alternativeRoute: alternativeRoute)
            print("Alternative route selected")
        } else {
            core.navigation().selectAlternativeRoute(with: alternativeRoute.routeId)
            print("Alternative route selected in active navigation")
        }
    }

    func requestRoutes(to mapPoint: MapPoint) async throws {
        guard !isInActiveNavigation, let currentLocation else {
            print("Error: Current location is unavailable")
            return
        }

        print("Requesting route from \(currentLocation.coordinate) to \(mapPoint.coordinate)")

        waypoints.append(Waypoint(coordinate: mapPoint.coordinate, name: mapPoint.name))
        var userWaypoint = Waypoint(location: currentLocation)
        if currentLocation.course >= 0, !shouldRequestMapMatching {
            userWaypoint.heading = currentLocation.course
            userWaypoint.headingAccuracy = 90
        }
        var optionsWaypoints = waypoints
        optionsWaypoints.insert(userWaypoint, at: 0)

        let provider = core.routingProvider()
        do {
            if shouldRequestMapMatching {
                let mapMatchingOptions = NavigationMatchOptions(
                    waypoints: optionsWaypoints,
                    profileIdentifier: profileIdentifier
                )
                let previewRoutes = try await provider.calculateRoutes(options: mapMatchingOptions).value
                currentPreviewRoutes = previewRoutes
                print("Route preview calculated with map matching: \(previewRoutes)")
            } else {
                let routeOptions = NavigationRouteOptions(
                    waypoints: optionsWaypoints,
                    profileIdentifier: profileIdentifier
                )
                let previewRoutes = try await provider.calculateRoutes(options: routeOptions).value
                currentPreviewRoutes = previewRoutes
                print("Route preview calculated without map matching: \(previewRoutes)")
            }
        } catch {
            print("Error while calculating routes: \(error.localizedDescription)")
        }
    }

}
