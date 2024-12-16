import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @Binding var isLoggedIn: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showErrorMessage = false
    @State private var showLoginView = false

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        email.contains("@") &&
        email.contains(".") &&
        password.count >= 6 &&
        password == confirmPassword
    }

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Spacer()
            
            // First Name Field
            InputField(icon: "person", placeholder: "First Name", text: $firstName)

            // Last Name Field
            InputField(icon: "person", placeholder: "Last Name", text: $lastName)

            // Email Field
            InputField(icon: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)

            // Password Field
            InputField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)

            // Confirm Password Field
            InputField(icon: "lock", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)

            // Error Message
            if showErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 5)
            }

            // Register Button
            Button(action: registerUser) {
                Text("Register")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isFormValid) // Disable button if form is not valid
            .padding(.top)

            // Login Button
            Button(action: { showLoginView = true }) {
                Text("Already have an account? Log in")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .underline()
                    .padding(.top, 10)
            }
            .sheet(isPresented: $showLoginView) {
                LoginView(isLoggedIn: $isLoggedIn)
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Register User
    private func registerUser() {
        guard isFormValid else {
            errorMessage = "Please make sure all fields are filled out correctly."
            showErrorMessage = true
            return
        }

        // Create user with Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorMessage = true
            } else if let user = result?.user {
                // Optionally update the user's display name with first and last name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating display name: \(error.localizedDescription)")
                    }
                }
                isLoggedIn = true
                UserDefaults.standard.set(true, forKey: "loggedIn")
            }
        }
    }
}

// MARK: - Reusable InputField View
struct InputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $text)
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

