import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AppStartView: View {
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
    @State private var showSplash = true
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
    @ObservedObject var navigation: Navigation

    var body: some View {
        Group {
            if showSplash {
                SplashView().onAppear { startSplash() }
            } else if !isOnboardingComplete {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            } else if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
            } else {
                ContentView(navigation: navigation)
            }
        }
    }

    private func startSplash() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSplash = false }
        }
    }
}


import SwiftUI
import FirebaseAuth
//
//struct LoginView: View {
//    @Binding var isLoggedIn: Bool
//    @State private var email = ""
//    @State private var password = ""
//    @State private var errorMessage = ""
//    @State private var showErrorMessage = false
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                // Title and Subtitle
//                VStack(spacing: 8) {
//                    Text("Welcome Back")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.center)
//                    
//                    Text("Login to continue")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                }
//                .padding(.top, 60)
//
//                Spacer()
//
//                // Email Field
//                CustomInputField(
//                    iconName: "envelope",
//                    placeholder: "Enter your email",
//                    text: $email,
//                    isSecure: false,
//                    keyboardType: .emailAddress
//                )
//
//                // Password Field
//                CustomInputField(
//                    iconName: "lock",
//                    placeholder: "Enter your password",
//                    text: $password,
//                    isSecure: true
//                )
//
//                // Error Message
//                if showErrorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .font(.footnote)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                        .padding(.top, 5)
//                }
//
//                // Login Button
//                Button(action: {
//                    loginUser()
//                }) {
//                    Text("Login")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                .padding(.top)
//                .disabled(email.isEmpty || password.isEmpty) // Disable if fields are empty
//
//                // Skip Button
//                Button(action: {
//                    isLoggedIn = true
//                    UserDefaults.standard.set(true, forKey: "loggedIn")
//                }) {
//                    Text("Skip")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                        .underline()
//                }
//                .padding(.top, 8)
//
//                // Register Navigation
//                NavigationLink(destination: RegisterView(isLoggedIn: $isLoggedIn)) {
//                    Text("Don't have an account? Register")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(10)
//                }
//                .padding(.top, 10)
//
//                Spacer()
//            }
//            .padding()
//            .background(Color(UIColor.systemBackground).ignoresSafeArea())
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//
//    // MARK: - Login User
//    private func loginUser() {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//                showErrorMessage = true
//            } else {
//                isLoggedIn = true
//                UserDefaults.standard.set(true, forKey: "loggedIn")
//            }
//        }
//    }
//}

// MARK: - Custom Input Field
struct CustomInputField: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(10)
    }
}
//
//
//// MARK: - Splash Screen
//struct SplashView: View {
//    var body: some View {
//        VStack {
//            Image("YourLogoImageName")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 120, height: 120)
//                .shadow(radius: 10)
//          
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.blue)
//        .foregroundColor(.white)
//        .ignoresSafeArea()
//    }
//}
//
//// Onboarding View
//struct OnboardingView: View {
//    @Binding var isOnboardingComplete: Bool
//    @State private var currentPage = 0
//
//    var body: some View {
//        VStack {
//            TabView(selection: $currentPage) {
//                OnboardingPageView(imageName: "map", title: "Discover Routes", description: "Find routes easily and navigate with Mapbox.", page: 0)
//                    .tag(0)
//
//                OnboardingPageView(imageName: "gearshape", title: "Customize Settings", description: "Adjust your settings and preferences.", page: 1)
//                    .tag(1)
//
//                OnboardingPageView(imageName: "list.bullet", title: "Track Your Journeys", description: "Keep track of your routes with detailed reports.", page: 2)
//                    .tag(2)
//            }
//            .tabViewStyle(PageTabViewStyle())
//            .ignoresSafeArea()
//
//            // Next and Skip Buttons
//            HStack {
//                Button(action: {
//                    // Skip directly to end of onboarding
//                    UserDefaults.standard.set(true, forKey: "onboardingComplete")
//                    isOnboardingComplete = true
//                }) {
//                    Text("Skip")
//                        .font(.title2)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.gray.opacity(0.2))
//                        .foregroundColor(.blue)
//                        .cornerRadius(10)
//                }
//
//                Button(action: {
//                    if currentPage < 2 {
//                        currentPage += 1
//                    } else {
//                        UserDefaults.standard.set(true, forKey: "onboardingComplete")
//                        isOnboardingComplete = true
//                    }
//                }) {
//                    Text(currentPage < 2 ? "Next" : "Get Started")
//                        .font(.title2)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//struct OnboardingPageView: View {
//    let imageName: String
//    let title: String
//    let description: String
//    let page: Int
//
//    var body: some View {
//        VStack {
//            Spacer()
//            Image(systemName: imageName)
//                .resizable()
//                .frame(width: 100, height: 100)
//                .padding()
//            Text(title)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding()
//            Text(description)
//                .font(.body)
//                .multilineTextAlignment(.center)
//                .padding()
//            Spacer()
//        }
//        .tag(page)
//    }
//}

struct ContentView: View {
    @ObservedObject var navigation: Navigation
    @StateObject private var favoritesViewModel = FavoritesViewModel.shared  // Use singleton instance

    
    @State private var favoritePlaces: [Location] = [] // Define as an array of Location

    let locationDictionary: [String: Location] = [
        "Computer Science": Location(title: "Computer Science", lat: 33.882332, lon: -117.882660, altitude: 0.0, type: TestAnnotationType.computerScience),
        "Computer Science 1": Location(title: "Computer Science 1", lat: 33.882332, lon: -117.882660, altitude: 10.0, type: TestAnnotationType.computerScience),
        "Computer Science 2": Location(title: "Computer Science 2", lat: 33.882332, lon: -117.882660, altitude: 20.0, type: TestAnnotationType.computerScience),
        "Computer Science 3": Location(title: "Computer Science 3", lat: 33.882332, lon: -117.882660, altitude: 30.0, type: TestAnnotationType.computerScience),
        "Engineering": Location(title: "Engineering", lat: 33.882310, lon: -117.883218, altitude: 0.0, type: TestAnnotationType.engineering),
        "College Park": Location(title: "College Park", lat: 33.877629, lon: -117.8835604, altitude: 0.0, type: TestAnnotationType.park),
        "Education-Classroom (EC)": Location(title: "Education-Classroom (EC)", lat: 33.881262, lon: -117.884343, altitude: 0.0, type: TestAnnotationType.education),
        "Humanities": Location(title: "Humanities", lat: 33.8804109, lon: -117.8844548, altitude: 0.0, type: TestAnnotationType.humanities),
        "McCarthy Hall": Location(title: "McCarthy Hall", lat: 33.8796612, lon: -117.8862273, altitude: 0.0, type: TestAnnotationType.mccarthyHall),
        "Dan Black Hall": Location(title: "Dan Black Hall", lat: 33.8791919, lon: -117.8860329, altitude: 0.0, type: TestAnnotationType.danBlackHall),
        "Health Center": Location(title: "Health Center", lat: 33.883011, lon: -117.884225, altitude: 0.0, type: TestAnnotationType.healthCenter),
        "Titan Gym": Location(title: "Titan Gym", lat: 33.883082, lon: -117.887582, altitude: 0.0, type: TestAnnotationType.gymnasium),
        "Titan Student Union": Location(title: "Titan Student Union", lat: 33.881350, lon: -117.887668, altitude: 0.0, type: TestAnnotationType.studentUnion),
        "Kinesiology and Health Science": Location(title: "Kinesiology and Health Science", lat: 33.882819, lon: -117.885430, altitude: 0.0, type: TestAnnotationType.kinesiology),
        "Clayes Performing Arts Center": Location(title: "Clayes Performing Arts Center", lat: 33.880463, lon: -117.886648, altitude: 0.0, type: TestAnnotationType.performingArts),
        "Titan Recreation Center": Location(title: "Titan Recreation Center", lat: 33.882973, lon: -117.887792, altitude: 0.0, type: TestAnnotationType.gymnasium),
        "Titan Shop": Location(title: "Titan Shop", lat: 33.881920, lon: -117.886820, altitude: 0.0, type: TestAnnotationType.library),
        "Nutwood Parking Structure": Location(title: "Nutwood Parking Structure", lat: 33.8792741, lon: -117.8887994, altitude: 0.0, type: TestAnnotationType.parkingLot),
        "Titan Hall": Location(title: "Titan Hall", lat: 33.880846, lon: -117.890127, altitude: 0.0, type: TestAnnotationType.universityHall),
        "CSUF Police": Location(title: "CSUF Police", lat: 33.883140, lon: -117.889384, altitude: 0.0, type: TestAnnotationType.universityHall),
        "Pollak Library": Location(title: "Pollak Library", lat: 33.88148526699614, lon: -117.88539035273149, altitude: 0.0, type: TestAnnotationType.library),
        "Visual Arts": Location(title: "Visual Arts", lat: 33.880352, lon: -117.888445, altitude: 0.0, type: TestAnnotationType.visualArts),
        "Financial Aid Office": Location(title: "Financial Aid Office", lat: 33.879757, lon: -117.884189, altitude: 0.0, type: TestAnnotationType.financialAidOffice),
        "Langsdorf Hall": Location(title: "Langsdorf Hall", lat: 33.878932, lon: -117.884650, altitude: 0.0, type: TestAnnotationType.langsdorfHall),
        "Steven G. Mihaylo Hall": Location(title: "Steven G. Mihaylo Hall", lat: 33.878633, lon: -117.883338, altitude: 0.0, type: TestAnnotationType.mihayloHall),
        "CSUF Housing": Location(title: "CSUF Housing", lat: 33.883649, lon: -117.881816, altitude: 0.0, type: TestAnnotationType.dormitory),
        "Ruby Gerontology Center": Location(title: "Ruby Gerontology Center", lat: 33.883641, lon: -117.883249, altitude: 0.0, type: TestAnnotationType.rubyCenter),
        "Titan Dining": Location(title: "Titan Dining", lat: 33.883119, lon: -117.882486, altitude: 0.0, type: TestAnnotationType.cafeteria),
        "Titan House": Location(title: "Titan House", lat: 33.884164, lon: -117.884137, altitude: 0.0, type: TestAnnotationType.dormitory),
        "Anderson Family Field": Location(title: "Anderson Family Field", lat: 33.885952, lon: -117.885010, altitude: 0.0, type: TestAnnotationType.dormitory),
        "Goodwin Field": Location(title: "Goodwin Field", lat: 33.887029, lon: -117.885451, altitude: 0.0, type: TestAnnotationType.dormitory),
        "Titan Stadium": Location(title: "Titan Stadium", lat: 33.886743, lon: -117.887002, altitude: 0.0, type: TestAnnotationType.gymnasium)

        
        
        
        // Add more locations here...
    ]

    var body: some View {
        TabView {
            // Pass both favoritesViewModel and locationDictionary to NewsTabView
           
            MapTabView(navigation: navigation, locationDictionary: locationDictionary, favoritesViewModel: favoritesViewModel)
                          .tabItem {
                              Label("Routes", systemImage: "map")
                          }
            NewsTabView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }

          //  ViewControllerWrapper()
          //      .tabItem {
           //         Label("LivePath", systemImage: "location")
          //      }

            SettingsTabView(navigation: navigation)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            favoritesViewModel.loadFavorites()
        }
    }
}








