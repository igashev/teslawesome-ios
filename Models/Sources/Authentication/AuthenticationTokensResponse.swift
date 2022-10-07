public struct AuthenticationTokensResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let idToken: String
    public let expiresIn: Int
    public let tokenType: String
}

#if DEBUG
public extension AuthenticationTokensResponse {
    static var stub: Self {
        .init(accessToken: "sada", refreshToken: "sada", idToken: "afafa", expiresIn: 3800, tokenType: "accessToken")
    }
}
#endif
