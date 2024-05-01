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

import VehiclesDataModels

struct AppReducer: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var hasEverBeenAuthenticated = false
        var isLoading = false
        var selectedVehicle: VehicleBasic?
    }

    enum Action {
        case didAppear
        case didReceiveVehiclesList(VehiclesBasicResponse)
    }
    
    @Dependency(\.authenticationFacadeClient) var authenticationFacadeClient
    @Dependency(\.vehiclesDataNetworkClient) var vehiclesDataNetworkClient
    
    var body: some ReducerOf<AppReducer> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                let hasEverBeenAuthenticated = authenticationFacadeClient.cachedAuthenticationToken != nil
                state.hasEverBeenAuthenticated = hasEverBeenAuthenticated
                
                if hasEverBeenAuthenticated {
                    state.isLoading = true
                    return .run { send in
                        let vehicles = try await vehiclesDataNetworkClient.getVehicles()
                        await send(.didReceiveVehiclesList(vehicles))
                    }
                } else {
                    return .none
                }
            case .didReceiveVehiclesList(let vehicleResponse):
                state.selectedVehicle = vehicleResponse.response.first
                state.isLoading = false
                return .none
            }
        }
    }
}

@main
struct TeslawesomeApp: App {
    let store: StoreOf<AppReducer>
    
    init() {
        Networking.appendMiddleware(
            AuthenticationTokenMiddleware(authenticationFacadeClient: .liveValue),
            LoggingMiddleware.live
        )
        
        self.store = .init(initialState: .init(), reducer: { AppReducer() })
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if store.hasEverBeenAuthenticated {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        if let selectedVehicle = store.selectedVehicle {
                            NavigationStack {
                                VehicleOverviewView(
                                    store: .init(
                                        initialState: VehicleOverview.State(selectedVehicleBasic: selectedVehicle),
                                        reducer: {
                                            VehicleOverview()
                                                .dependency(\.vehiclesDataNetworkClient, .previewValue)
                                        }
                                    )
                                )
                            }
                        } else {
                            VehiclesListView(store: .init(initialState: .init(), reducer: { VehiclesList() }))
                        }
                    }
                } else {
                    LoginView(store: .init(initialState: .init(), reducer: { Login() }))
                }
            }
            .onAppear {
                store.send(.didAppear)
            }
        }
    }
}
