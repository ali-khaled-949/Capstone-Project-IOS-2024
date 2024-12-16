import SwiftUI
import CoreLocation
import MapboxNavigationCore
import UIKit

// MARK: - MapView Wrapper for MapViewController

struct MapView: UIViewControllerRepresentable {
    let navigation: Navigation

    func makeUIViewController(context: Context) -> UIViewController {
        MapViewController(navigation: navigation)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - MapTabView

struct MapTabView: View {
    @ObservedObject var navigation: Navigation
    @State private var showingFavorites = false
    let locationDictionary: [String: Location]
    @ObservedObject var favoritesViewModel: FavoritesViewModel
//    var favoritePlaces: [Location]  // Pass your favorite places here

    var body: some View {
        ZStack {
            VStack {
                MapView(navigation: navigation)
                    .ignoresSafeArea(.all)
                
                RouteControlsView(navigation: navigation) // Extracted route controls into a subview for clarity
            }
            
            if navigation.isInActiveNavigation {
                NavigationControlsView(navigation: navigation) // Overlay for active navigation controls
            }
            
          //  LiveDataView(navigation: navigation) // Overlay for live data view
            
            ShowFavoritesButton(showingFavorites: $showingFavorites) // Button to show favorite locations
        }
        .sheet(isPresented: $showingFavorites) {
            // Pass necessary data to FavoritePlacesView
            FavoritePlacesView(
                favoritesViewModel: favoritesViewModel,
                locationDictionary: locationDictionary,
                onLocationSelected: handleLocationSelection
            )
        }
    }

    // MARK: - Handle Location Selection
    private func handleLocationSelection(_ selectedLocation: Location) {
        let coordinate = CLLocationCoordinate2D(latitude: selectedLocation.lat, longitude: selectedLocation.lon)
        showingFavorites = false // Close the favorites sheet
        
        Task {
            do {
                let mapPoint = MapPoint(name: selectedLocation.title, coordinate: coordinate)
                try await navigation.requestRoutes(to: mapPoint)
            } catch {
                print("Error requesting route: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - RouteControlsView

struct RouteControlsView: View {
    @ObservedObject var navigation: Navigation

    var body: some View {
        if navigation.currentPreviewRoutes == nil, !navigation.isInActiveNavigation {
            Text("Long press anywhere to build a route")
                .padding()
        } else if navigation.currentPreviewRoutes != nil {
            HStack {
                ClearButton(action: {
                    Task { @MainActor in
                        navigation.cancelPreview()
                    }
                })
                Spacer()
                StartNavigationButton(action: {
                    Task { @MainActor in
                        navigation.startActiveNavigation()
                    }
                })
            }
            .padding()
        }
    }
}

struct ClearButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Clear")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 10)
    }
}

struct StartNavigationButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Start Navigation")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - ShowFavoritesButton

struct ShowFavoritesButton: View {
    @Binding var showingFavorites: Bool

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                showingFavorites.toggle()
            }) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.orange)
                    .clipShape(Circle())
            }
            .padding(.bottom, 110)
            .offset(x: 180)
        }
    }
}

// MARK: - FavoritePlacesView

struct FavoritePlacesView: View {
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    let locationDictionary: [String: Location]
    var onLocationSelected: (Location) -> Void

    var body: some View {
        NavigationView {
            VStack {
                if favoritesViewModel.favoriteLocations.isEmpty {
                    Text("No favorite locations saved yet.")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(favoritesList, id: \.id) { location in
                            LocationCardView(location: location, favoritesViewModel: favoritesViewModel)
                                .onTapGesture {
                                    onLocationSelected(location)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Favorite Locations")
            .onAppear {
                favoritesViewModel.loadFavorites()
            }
        }
    }

    // Computed property to filter and retrieve favorite locations from the dictionary
    private var favoritesList: [Location] {
        favoritesViewModel.favoriteLocations.keys.compactMap { locationName in
            locationDictionary[locationName]
        }
    }
}
