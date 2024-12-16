import SwiftUI
import MapboxNavigationCore
import FirebaseAuth
import FirebaseFirestore

struct SettingsTabView: View {
    @ObservedObject var navigation: Navigation
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
    @State private var username: String?
    @State private var email: String?
    @AppStorage("isDarkMode") private var isDarkMode = false // Use @AppStorage to persist the theme choice
    @State private var notificationsEnabled = true
    @State private var showRegisterView = false
    @State private var showDeleteAccountAlert = false
    @StateObject private var favoritesViewModel = FavoritesViewModel.shared  // Use singleton instance

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Profile Section
                    userProfileSection
                    Divider()

                    // Favorites Section
                    if isLoggedIn {
                        favoritesSection
                        Divider()
                    }

                    // Settings Toggles
                    settingsSection
                    Divider()

                    // Action Buttons
                    if isLoggedIn {
                        actionButtons
                    }

                    Spacer()
                    footerText
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            fetchUserData()
            if isLoggedIn {
                favoritesViewModel.loadFavorites()
            }
        }
    }

    // MARK: - User Profile Section
    private var userProfileSection: some View {
        Group {
            if isLoggedIn {
                VStack(alignment: .leading, spacing: 10) {
                    Text("User Profile")
                        .font(.headline)
                        .fontWeight(.bold)

                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(username ?? "Username")
                                .font(.title3)
                                .fontWeight(.medium)
                            Text(email ?? "user@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemBackground)))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            } else {
                Button(action: { showRegisterView = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Login to Profile")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray6)))
                }
                .sheet(isPresented: $showRegisterView) {
                    RegisterView(isLoggedIn: $isLoggedIn)
                }
            }
        }
    }

    // MARK: - Favorites Section
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Favorite Locations")
                .font(.headline)

            ForEach(favoritesViewModel.favoritePlaces, id: \.title) { location in
                HStack {
                    Text(location.title)
                        .font(.body)
                    Spacer()
                    Button(action: {
                        favoritesViewModel.toggleFavorite(locationTitle: location.title)
                    }) {
                        Image(systemName: favoritesViewModel.favoriteLocations[location.title] == true ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground)))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    // MARK: - Settings Toggles
    private var settingsSection: some View {
        VStack(spacing: 15) {
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: "moon.fill")
                    .font(.title3)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .padding(.horizontal)

            Toggle(isOn: $notificationsEnabled) {
                Label("Enable Notifications", systemImage: "bell.fill")
                    .font(.title3)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .padding(.horizontal)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground)))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button(action: { logoutUser() }) {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .foregroundColor(.red)
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6)))
            }

            Button(action: { showDeleteAccountAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6)))
            }
            .alert(isPresented: $showDeleteAccountAlert) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAccount()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // MARK: - Footer Text
    private var footerText: some View {
        Text("Settings and Configurations")
            .font(.footnote)
            .foregroundColor(.gray)
            .padding(.top, 20)
    }

    // MARK: - Fetch User Data
    private func fetchUserData() {
        if let user = Auth.auth().currentUser {
            let components = user.displayName?.split(separator: " ")
            let firstName = components?.first.map { String($0) } ?? "First Name"
            let lastName = components?.last.map { String($0) } ?? "Last Name"
            self.username = "\(firstName) \(lastName)"
            self.email = user.email
        }
    }

    // MARK: - Logout Function
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            UserDefaults.standard.set(false, forKey: "loggedIn")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Account Function
    private func deleteAccount() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                } else {
                    isLoggedIn = false
                    UserDefaults.standard.set(false, forKey: "loggedIn")
                    print("Account successfully deleted.")
                }
            }
        }
    }
}
