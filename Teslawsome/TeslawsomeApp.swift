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

struct AppReducer: ReducerProtocol {
    struct State: Equatable {
        var hasEverBeenAuthenticated: Bool = false
    }

    enum Action {
        case didAppear
    }
    
    @Dependency(\.authenticationFacadeClient) var authenticationFacadeClient
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didAppear:
            let hasEverBeenAuthenticated = authenticationFacadeClient.cachedAuthenticationToken != nil
            state.hasEverBeenAuthenticated = hasEverBeenAuthenticated
            return .none
        }
    }
}

@main
struct TeslawsomeApp: App {
    @ObservedObject var viewStore: ViewStoreOf<AppReducer>
    
    init() {
        Networking.appendMiddleware(
            AuthenticationTokenMiddleware(authenticationFacadeClient: .liveValue),
            LoggingMiddleware.live
        )
        
        self.viewStore = .init(.init(initialState: .init(), reducer: AppReducer()), observe: { $0 })
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if viewStore.hasEverBeenAuthenticated {
                    VehiclesListView(store: .init(initialState: .init(), reducer: VehiclesList()))
                } else {
                    LoginView(store: .init(initialState: .init(), reducer: Login()))
                }
            }
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
    }
}

import AppIntents

struct FlashLightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Flash Tesla lights"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("Coool")
        return .result(dialog: "Ok COOl!")
    }
}
