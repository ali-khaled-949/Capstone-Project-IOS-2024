import SwiftUI
import FirebaseAuth
import FirebaseFirestore



struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showErrorMessage = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title and Subtitle
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Login to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                Spacer()

                // Email Field
                CustomInputField(
                    iconName: "envelope",
                    placeholder: "Enter your email",
                    text: $email,
                    isSecure: false,
                    keyboardType: .emailAddress
                )

                // Password Field
                CustomInputField(
                    iconName: "lock",
                    placeholder: "Enter your password",
                    text: $password,
                    isSecure: true
                )

                // Error Message
                if showErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 5)
                }

                // Login Button
                Button(action: {
                    loginUser()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top)
                .disabled(email.isEmpty || password.isEmpty) // Disable if fields are empty

                // Skip Button
                Button(action: {
                    isLoggedIn = true
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                }) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top, 8)

                // Register Navigation
                NavigationLink(destination: RegisterView(isLoggedIn: $isLoggedIn)) {
                    Text("Don't have an account? Register")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Login User
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorMessage = true
            } else {
                isLoggedIn = true
                UserDefaults.standard.set(true, forKey: "loggedIn")
            }
        }
    }
}
