//
//  ContentView.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 20.08.22.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationFacade
import AuthenticationModels

struct Login: ReducerProtocol {
    struct State: Equatable {
        let teslaAuthDomain = "https://auth.tesla.com/oauth2/v3/authorize"
        
        let clientID = "ownerapi"
        let redirectURL = "https://auth.tesla.com/void/callback"
        let responseType = "code"
        let scope = "openid email offline_access"
    //    let state = "state" // some random thing
        let loginHint = ""
    //    let codeChallenge = ""
        let codeChallengeMethod = "S256"
        
        @BindableState var fullTeslaAuthURL: URL?
        @BindableState var showVehicles: Bool = false
    }

    enum Action: BindableAction {
        case didTapSignInWithTeslaButton
        case didReceiveAuthCodeURL(url: URL)
        case requestBearerToken(authorizationCode: String, codeChallengeCode: String)
        case didReceiveBearerToken(TaskResult<AuthenticationToken>)
        case binding(BindingAction<State>)
    }
    
    struct Environment {
        let authenticationFacadeClient: AuthenticationFacadeClient
        let challengeCodeVerifier: String
        let generateRandomStringOfLength: (Int) -> String
        let hashSHA256: (String) -> String
        let encodeBase64URL: (String) -> String
        let extractQueryParameter: (URL, String) -> String?
        
        static var live: Self {
            .init(
                authenticationFacadeClient: .liveValue,
                challengeCodeVerifier: Utils.randomlyGeneratedString(lenght: 86),
                generateRandomStringOfLength: Utils.randomlyGeneratedString(lenght:),
                hashSHA256: Utils.hashInSHA256(string:),
                encodeBase64URL: Utils.encodeBase64URL(string:),
                extractQueryParameter: Utils.extractQueryParameterValue(from:queryName:)
            )
        }
        
        static var stub: Self {
            .init(
                authenticationFacadeClient: .liveValue,
                challengeCodeVerifier: Utils.randomlyGeneratedString(lenght: 86),
                generateRandomStringOfLength: Utils.randomlyGeneratedString(lenght:),
                hashSHA256: Utils.hashInSHA256(string:),
                encodeBase64URL: Utils.encodeBase64URL(string:),
                extractQueryParameter: Utils.extractQueryParameterValue(from:queryName:)
            )
        }
    }
    
    let environment: Environment
    
    init(environment: Environment = .live) {
        self.environment = environment
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didTapSignInWithTeslaButton:
                let codeChallengeRandomString = environment.challengeCodeVerifier
                let codeChallengeSHA256String = environment.hashSHA256(codeChallengeRandomString)
                let codeChallengeBase64URLEncoded = environment.encodeBase64URL(codeChallengeSHA256String)
                var urlComponents = URLComponents(string: state.teslaAuthDomain)
                urlComponents?.queryItems = [
                    .init(name: "client_id", value: state.clientID),
                    .init(name: "redirect_uri", value: state.redirectURL),
                    .init(name: "response_type", value: state.responseType),
                    .init(name: "scope", value: state.scope),
                    .init(name: "state", value: environment.generateRandomStringOfLength(10)),
                    .init(name: "login_hint", value: state.loginHint),
                    .init(name: "code_challenge", value: codeChallengeBase64URLEncoded),
                    .init(name: "code_challenge_method", value: state.codeChallengeMethod)
                ]
                
                state.fullTeslaAuthURL = urlComponents?.url
                return .none
            case .didReceiveAuthCodeURL(let url):
                state.fullTeslaAuthURL = nil
                
                let authorizationCode = environment.extractQueryParameter(url, "code") ?? ""
                let codeChallengeRandomString = environment.challengeCodeVerifier
                return Effect(value: .requestBearerToken(authorizationCode: authorizationCode, codeChallengeCode: codeChallengeRandomString))
            case .requestBearerToken(let authorizationCode, let codeChallengeCode):
                return .task {
                    let taskResult = await TaskResult {
                        try await environment.authenticationFacadeClient.getAuthenticationToken(
                            authorizationToken: authorizationCode,
                            codeVerifier: codeChallengeCode
                        )
                    }
                    
                    return .didReceiveBearerToken(taskResult)
                }
            case .didReceiveBearerToken(.success):
                state.showVehicles.toggle()
                return .none
            case .didReceiveBearerToken(.failure(let error)):
                print(error)
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct LoginView: View {
    @ObservedObject var viewStore: ViewStoreOf<Login>
    
    init(store: StoreOf<Login>) {
        self.viewStore = .init(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Sign in with Tesla") {
                    viewStore.send(.didTapSignInWithTeslaButton)
                }
                .font(.headline)
            }
            .sheet(item: viewStore.binding(\.$fullTeslaAuthURL)) { url in
                TeslaAuthWebView(url: url) { callbackURL in
                    viewStore.send(.didReceiveAuthCodeURL(url: callbackURL))
                }
            }
            .navigationDestination(isPresented: viewStore.binding(\.$showVehicles)) {
                VehiclesListView(store: .init(initialState: .init(), reducer: VehiclesList()))
            }
            .navigationTitle("Sign in")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: .init(initialState: .init(), reducer: Login()))
            .preferredColorScheme(.dark)
    }
}

extension URL: Identifiable {
    public var id: Int { hashValue }
}
