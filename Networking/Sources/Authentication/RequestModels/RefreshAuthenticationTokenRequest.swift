struct RefreshAuthenticationTokenRequest: Encodable {
    let grantType = AuthenticationTokenGrantType.refreshToken
    let clientID = "ownerapi"
    let refreshToken: String
    let scope = "openid email offline_access"
}
