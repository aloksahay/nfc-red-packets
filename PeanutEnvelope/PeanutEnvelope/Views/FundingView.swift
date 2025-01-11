import SwiftUI
import CoreNFC
import Web3Auth

struct FundingView: View {
    @ObservedObject var viewModel: WalletViewModel
    @State private var amount: String = ""
    @State private var showNFCWriter = false
    @State private var claimLink: String?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Amount in ETH", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: createPeanutLink) {
                HStack {
                    Image(systemName: "link.badge.plus")
                    Text("Create Claim Link")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            if let link = claimLink {
                Button(action: { showNFCWriter = true }) {
                    HStack {
                        Image(systemName: "wave.3.right")
                        Text("Write to NFC Tag")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showNFCWriter) {
            NFCWriteView(claimLink: claimLink ?? "")
        }
    }
    
    private func createPeanutLink() {
        Task {
            do {
                guard let amountFloat = Float(amount) else {
                    throw APIErrorType.invalidAmount
                }
                
                guard let web3auth = viewModel.web3Auth else {
                    throw APIErrorType.invalidSignature
                }
                
                let message = "Create Peanut Link for \(amount) ETH"
                var params = [Any]()
                params.append(message)
                
                let signature = try await web3auth.request(
                    chainConfig: ChainConfig(
                        chainNamespace: .eip155,
                        chainId: "11155111",
                        rpcTarget: "https://sepolia.infura.io/v3/\(Configuration.infuraKey)"
                    ),
                    method: "personal_sign",
                    requestParams: params
                )
                
                guard let signatureResult = signature.result else {
                    throw APIErrorType.invalidSignature
                }
                
                let url = URL(string: "\(Configuration.baseURL)/api/create-link")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "amount": String(amountFloat),
                    "tokenAddress": "0x0000000000000000000000000000000000000000", // ETH
                    "signature": signatureResult,
                    "message": message
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(PeanutResponse.self, from: data)
                
                await MainActor.run {
                    self.claimLink = response.data.link
                }
            } catch {
                print("Error creating Peanut link:", error)
                // TODO: Add proper error handling
            }
        }
    }
}
