import SwiftUI

struct LoginSheet: View {
    @Environment(AppState.self) private var appState
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                        .textContentType(isRegistering ? .newPassword : .password)
                }

                if let error = appState.error {
                    Section {
                        Text(error)
                            .foregroundStyle(Color(hex: "ff3b30"))
                            .font(.caption)
                    }
                }

                Section {
                    Button {
                        Task {
                            if isRegistering {
                                await appState.register(email: email, password: password)
                            } else {
                                await appState.login(email: email, password: password)
                            }
                        }
                    } label: {
                        if appState.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isRegistering ? "Create Account" : "Sign In")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || appState.isLoading)
                    .tint(Color(hex: "0071e3"))
                }

                Section {
                    Button {
                        isRegistering.toggle()
                        appState.error = nil
                    } label: {
                        Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Register")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.secondary)
                }
            }
            .navigationTitle(isRegistering ? "Register" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        appState.showLogin = false
                        appState.error = nil
                    }
                }
            }
        }
    }
}
