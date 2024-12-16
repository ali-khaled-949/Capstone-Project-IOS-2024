import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import CoreLocation

// Enum for location types to categorize different places
enum LocationType {
    case computerScience, engineering, park, education, humanities, library, gymnasium, dormitory, universityHall, cafeteria
}

final class FavoritesViewModel: ObservableObject {
    static let shared = FavoritesViewModel()  // Singleton instance

    @Published var favoriteLocations: [String: Bool] = [:]  // Track favorite status for each location
    private let db = Firestore.firestore()  // Firebase Firestore instance

    // Example list of locations with detailed attributes
    let favoritePlaces: [Location] = [
        Location(title: "Computer Science", lat: 33.882332, lon: -117.882660, altitude: 0.0, type: .computerScience),
        Location(title: "Computer Science 1", lat: 33.882332, lon: -117.882660, altitude: 10.0, type: .computerScience),
        Location(title: "Engineering", lat: 33.882310, lon: -117.883218, altitude: 0.0, type: .engineering),
        Location(title: "College Park", lat: 33.877629, lon: -117.8835604, altitude: 0.0, type: .park),
        Location(title: "Education-Classroom (EC)", lat: 33.881262, lon: -117.884343, altitude: 0.0, type: .education),
        Location(title: "Humanities", lat: 33.8804109, lon: -117.8844548, altitude: 0.0, type: .humanities),
        Location(title: "McCarthy Hall", lat: 33.8796612, lon: -117.8862273, altitude: 0.0, type: .library),
        Location(title: "Titan Gym", lat: 33.883082, lon: -117.887582, altitude: 0.0, type: .gymnasium),
        Location(title: "Titan Student Union", lat: 33.881350, lon: -117.887668, altitude: 0.0, type: .universityHall),
        Location(title: "Pollak Library", lat: 33.88148526699614, lon: -117.88539035273149, altitude: 0.0, type: .library),
        // Add more locations as needed
    ]

    private init() {}  // Private initializer to enforce singleton pattern

    func loadFavorites() {
        guard let user = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }

        // Initialize all locations to false by default
        favoriteLocations = Dictionary(uniqueKeysWithValues: favoritePlaces.map { ($0.title, false) })

        // Load favorites from Firestore
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data(), let favorites = data["favorites"] as? [String: Bool] {
                DispatchQueue.main.async {
                    self.favoriteLocations = favorites
                }
            } else {
                print("No data found or incorrect format")
                DispatchQueue.main.async {
                    self.favoriteLocations = Dictionary(uniqueKeysWithValues: self.favoritePlaces.map { ($0.title, false) })
                }
            }
        }
    }

    func toggleFavorite(locationTitle: String) {
        if let isFavorite = favoriteLocations[locationTitle] {
            favoriteLocations[locationTitle] = !isFavorite
        } else {
            favoriteLocations[locationTitle] = true
        }
        
        saveFavorites()  // Save updated favorites
    }

    private func saveFavorites() {
        guard let user = Auth.auth().currentUser else { return }
        db.collection("users").document(user.uid).setData(["favorites": favoriteLocations], merge: true) { error in
            if let error = error {
                print("Failed to save favorites: \(error.localizedDescription)")
            } else {
                print("Favorites saved successfully")
            }
        }
    }
}
