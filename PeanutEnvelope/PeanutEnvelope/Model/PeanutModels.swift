struct PeanutResponse: Codable {
    let success: Bool
    let data: PeanutLinkData
}

struct PeanutLinkData: Codable {
    let link: String
    let chainId: Int
    let tokenAddress: String
    let tokenDecimals: Int
    let tokenSymbol: String
} 