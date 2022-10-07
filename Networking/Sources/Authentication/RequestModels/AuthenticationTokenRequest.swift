struct AuthenticationTokenRequest: Encodable {
    let grantType = AuthenticationTokenGrantType.authorizationCode
    let clientId = "ownerapi"
    let code: String
    let codeVerifier: String
    let redirectUri = "https://auth.tesla.com/void/callback"
}
