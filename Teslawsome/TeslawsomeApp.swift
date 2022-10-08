//
//  TeslawsomeApp.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 20.08.22.
//

import SwiftUI
import ComposableArchitecture
import Networking
import AuthenticationFacade

struct AppState: Equatable {
    var hasEverBeenAuthenticated: Bool = false
}

enum AppAction {
    case didAppear
}

struct AppEnvironment {
    let authenticationFacadeClient: AuthenticationFacadeClient
    
    static var live: Self {
        .init(authenticationFacadeClient: .live)
    }
}

var appReducer: Reducer<AppState, AppAction, AppEnvironment> {
    .init { state, action, environment in
        switch action {
        case .didAppear:
            let hasEverBeenAuthenticated = environment.authenticationFacadeClient.cachedAuthenticationToken != nil
            state.hasEverBeenAuthenticated = hasEverBeenAuthenticated
            return .none
        }
    }
}

@main
struct TeslawsomeApp: App {
    let store: Store<AppState, AppAction>
    @ObservedObject var viewStore: ViewStore<AppState, AppAction>
    
    init() {
        Networking.appendMiddleware(
            AuthenticationTokenMiddleware(authenticationFacadeClient: .live),
            LoggingMiddleware.live
        )
        
        self.store = .init(initialState: .init(), reducer: appReducer, environment: .live)
        self.viewStore = .init(store)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if viewStore.hasEverBeenAuthenticated {
                    VehiclesListView(store: .init(initialState: .init(), reducer: vehiclesListReducer, environment: .live))
                } else {
                    LoginView(store: .init(initialState: LoginState(), reducer: loginReducer, environment: .live))
                }
            }
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
    }
}
