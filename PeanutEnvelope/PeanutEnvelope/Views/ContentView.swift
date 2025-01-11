//
//  ContentView.swift
//  PeanutEnvelope
//
//  Created by Alok Sahay on 07.01.2025.
//

import SwiftUI
import Web3Auth

struct ContentView: View {
    @StateObject private var viewModel = WalletViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Debug Text (remove in production)
                Text("Login State: \(viewModel.isLoggedIn ? "Logged In" : "Not Logged In")")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if viewModel.isLoggedIn {
                    // Wallet Header
                    WalletHeaderView(viewModel: viewModel)
                        .padding(.top)
                    
                    // Main interface after login
                    FundingView(viewModel: viewModel)
                } else {
                    // Login interface
                    VStack(spacing: 25) {
                        Image(systemName: "envelope.fill")
                            .imageScale(.large)
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                        
                        Text("Peanut Envelope")
                            .font(.title)
                            .bold()
                        
                        Text("Send crypto through NFC")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            print("Login button tapped")
                            viewModel.login()
                        }) {
                            HStack {
                                Image(systemName: "wallet.pass.fill")
                                Text("Connect Wallet")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .navigationTitle(viewModel.isLoggedIn ? "Create Link" : "Welcome")
        }
    }
}

#Preview {
    ContentView()
}
