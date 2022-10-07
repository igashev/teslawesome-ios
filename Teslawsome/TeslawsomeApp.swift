//
//  TeslawsomeApp.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 20.08.22.
//

import SwiftUI
import ComposableArchitecture
import CachingClient

struct AppState: Equatable {
    var hasEverBeenAuthenticated: Bool = false
}

enum AppAction {
    case didAppear
}

struct AppEnvironment {
    let cachingClient: CachingClient
    
    static var live: Self {
        .init(cachingClient: .live)
    }
}

var appReducer: Reducer<AppState, AppAction, AppEnvironment> {
    .init { state, action, environment in
        switch action {
        case .didAppear:
            let hasEverBeenAuthenticated = environment.cachingClient.getToken() != nil
            state.hasEverBeenAuthenticated = hasEverBeenAuthenticated
            return .none
        }
    }
}

@main
struct TeslawsomeApp: App {
    let store: Store<AppState, AppAction> = .init(initialState: .init(), reducer: appReducer, environment: .live)
    @ObservedObject var viewStore: ViewStore<AppState, AppAction>
    
    init() {
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
