enum APIErrorType: Error {
    case invalidAmount
    case invalidResponse
    case networkError(String)
    case invalidSignature
} 
