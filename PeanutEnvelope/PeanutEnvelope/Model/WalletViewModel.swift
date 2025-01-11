import Foundation
import Web3Auth
import CoreNFC

class WalletViewModel: ObservableObject {
    @Published var web3Auth: Web3Auth?
    @Published var isLoggedIn = false
    @Published var user: Web3AuthState?
    @Published var isLoading = false
    @Published var error: String?
    @Published var balance: String?
    @Published var ethAddress: String?
    
    init() {
        setupWeb3Auth()
    }
    
    private func setupWeb3Auth() {
        Task {
            do {
                let params = W3AInitParams(
                    clientId: Configuration.web3AuthClientId,
                    network: .sapphire_devnet,
                    redirectUrl: Configuration.appRedirectUrl
                )
                
                let auth = try await Web3Auth(params)
                
                await MainActor.run {
                    self.web3Auth = auth
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                }
                print("Web3Auth initialization failed with error: ", error.localizedDescription)
            }
        }
    }
    
    func login() {
        isLoading = true
        print("Starting login process...")
        
        Task {
            do {
                let result = try await web3Auth?.login(W3ALoginParams(
                    loginProvider: .GOOGLE
                ))
                
                await MainActor.run {
                    if let state = result {
                        self.user = state
                        self.isLoggedIn = true
                        
                        // Get private key and derive Ethereum address
                        if let privateKey = state.ed25519PrivKey {
                            print("Wallet things ")
//                            let wallet = try? Wallet(privateKey: privateKey)
//                            self.ethAddress = wallet?.address
//                            print("ETH Address: \(self.ethAddress ?? "none")")
                            
//                            if let address = self.ethAddress {
//                                self.fetchBalance(address: address)
//                            }
                        }
                    } else {
                        print("Login failed: No state returned")
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    print("Login error: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    func fetchBalance(address: String) {
        Task {
            do {
                let url = URL(string: "https://sepolia.infura.io/v3/\(Configuration.infuraKey)")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let params: [String: Any] = [
                    "jsonrpc": "2.0",
                    "method": "eth_getBalance",
                    "params": [address, "latest"],
                    "id": 1
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(EthBalanceResponse.self, from: data)
                
                if let balanceHex = response.result {
                    let balanceWei = BigInt(balanceHex.dropFirst(2), radix: 16) ?? BigInt(0)
                    let balanceEth = Double(balanceWei) / 1e18
                    
                    await MainActor.run {
                        self.balance = String(format: "%.4f", balanceEth)
                    }
                }
            } catch {
                print("Error fetching balance:", error)
            }
        }
    }
}

struct EthBalanceResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: String?
} 
