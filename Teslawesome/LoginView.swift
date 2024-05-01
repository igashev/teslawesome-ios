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

@Reducer
struct Login {
    @ObservableState
    struct State: Equatable {
        var codeVerifier = ""
        var fullTeslaAuthURL: URL?
        var showVehicles: Bool = false
    }

    enum Action: BindableAction {
        case didTapSignInWithTeslaButton
        case didReceiveAuthCodeURL(url: URL)
        case didReceiveBearerToken(AuthenticationToken)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.authenticationFacadeClient) var authenticationFacadeClient
    
    var body: some ReducerOf<Login> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .didTapSignInWithTeslaButton:
                state.codeVerifier = authenticationFacadeClient.generateLoginCodeVerifier()
                let loginUrl = authenticationFacadeClient.generateLoginURL(codeVerifier: state.codeVerifier)
                state.fullTeslaAuthURL = loginUrl
                return .none
            case .didReceiveAuthCodeURL(let url):
                state.fullTeslaAuthURL = nil
                
                let authorizationCode = authenticationFacadeClient.extractAuthorizationCodeFromURL(url) ?? "" // maybe throw an error
                return requestBearerToken(authorizationCode: authorizationCode, codeVerifier: state.codeVerifier)
            case .didReceiveBearerToken:
                state.showVehicles.toggle()
                return .none
            case .binding:
                return .none
            }
        }
    }
    
    private func requestBearerToken(authorizationCode: String, codeVerifier: String) -> Effect<Action> {
        .run { send in
            let token = try await authenticationFacadeClient.getAuthenticationToken(
                authorizationToken: authorizationCode,
                codeVerifier: codeVerifier
            )
            
            await send(.didReceiveBearerToken(token))
        }
    }
}

struct LoginView: View {
    @Bindable var store: StoreOf<Login>
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Sign in with Tesla") {
                    store.send(.didTapSignInWithTeslaButton)
                }
                .font(.headline)
            }
            .sheet(item: $store.fullTeslaAuthURL) { url in
                TeslaAuthWebView(url: url) { callbackURL in
                    store.send(.didReceiveAuthCodeURL(url: callbackURL))
                }
            }
            .sheet(isPresented: $store.showVehicles) {
                VehiclesListView(store: .init(initialState: .init(), reducer: { VehiclesList() }))
            }
            .navigationTitle("Sign in")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: .init(initialState: .init(), reducer: { Login() }))
            .preferredColorScheme(.dark)
    }
}

extension URL: Identifiable {
    public var id: Int { hashValue }
}
