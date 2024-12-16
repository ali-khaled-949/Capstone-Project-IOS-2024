import SwiftUI
import FirebaseAuth
import FirebaseFirestore


// MARK: - Splash Screen
struct SplashView: View {
    var body: some View {
        VStack {
            Image("YourLogoImageName")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .shadow(radius: 10)
          
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .foregroundColor(.white)
        .ignoresSafeArea()
    }
}

// Onboarding View
struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(imageName: "map", title: "Discover Routes", description: "Find routes easily and navigate with Mapbox.", page: 0)
                    .tag(0)

                OnboardingPageView(imageName: "gearshape", title: "Customize Settings", description: "Adjust your settings and preferences.", page: 1)
                    .tag(1)

                OnboardingPageView(imageName: "list.bullet", title: "Track Your Journeys", description: "Keep track of your routes with detailed reports.", page: 2)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea()

            // Next and Skip Buttons
            HStack {
                Button(action: {
                    // Skip directly to end of onboarding
                    UserDefaults.standard.set(true, forKey: "onboardingComplete")
                    isOnboardingComplete = true
                }) {
                    Text("Skip")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }

                Button(action: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        UserDefaults.standard.set(true, forKey: "onboardingComplete")
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let page: Int

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .tag(page)
    }
}
