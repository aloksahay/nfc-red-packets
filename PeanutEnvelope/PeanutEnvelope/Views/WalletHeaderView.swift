import SwiftUI

struct WalletHeaderView: View {
    @ObservedObject var viewModel: WalletViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                // Wallet Address
                Text(viewModel.shortenedAddress ?? "")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                // Balance
                if let balance = viewModel.balance {
                    Text("\(balance) ETH")
                        .font(.subheadline)
                        .bold()
                } else {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal)
        }
    }
} 
