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
        var codeVerifier = ""
        @BindableState var fullTeslaAuthURL: URL?
        @BindableState var showVehicles: Bool = false
    }

    enum Action: BindableAction {
        case didTapSignInWithTeslaButton
        case didReceiveAuthCodeURL(url: URL)
        case requestBearerToken(authorizationCode: String, codeVerifier: String)
        case didReceiveBearerToken(TaskResult<AuthenticationToken>)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.authenticationFacadeClient) var authenticationFacadeClient
    
    var body: some ReducerProtocol<State, Action> {
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
                return Effect(value: .requestBearerToken(authorizationCode: authorizationCode, codeVerifier: state.codeVerifier))
            case .requestBearerToken(let authorizationCode, let codeChallengeCode):
                return .task {
                    let taskResult = await TaskResult {
                        try await authenticationFacadeClient.getAuthenticationToken(
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
            .sheet(isPresented: viewStore.binding(\.$showVehicles)) {
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
