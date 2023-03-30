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

struct AppReducer: ReducerProtocol {
    struct State: Equatable {
        var hasEverBeenAuthenticated = false
        var isLoading = false
        var selectedVehicle: VehicleBasic?
    }

    enum Action {
        case didAppear
        case didReceiveVehiclesList(TaskResult<VehiclesBasicResponse>)
    }
    
    @Dependency(\.authenticationFacadeClient) var authenticationFacadeClient
    @Dependency(\.vehiclesDataNetworkClient) var vehiclesDataNetworkClient
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didAppear:
            let hasEverBeenAuthenticated = authenticationFacadeClient.cachedAuthenticationToken != nil
            state.hasEverBeenAuthenticated = hasEverBeenAuthenticated
            
            if hasEverBeenAuthenticated {
                state.isLoading = true
                return .task {
                    let taskResult = await TaskResult {
                        try await vehiclesDataNetworkClient.getVehicles()
                    }
                    
                    return .didReceiveVehiclesList(taskResult)
                }
            } else {
                return .none
            }
        case .didReceiveVehiclesList(let result):
            switch result {
            case .success(let vehicleResponse):
                state.selectedVehicle = vehicleResponse.response.first
            case .failure(let error):
                print(error)
            }
            
            state.isLoading = false
            return .none
        }
    }
}

@main
struct TeslawesomeApp: App {
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
                    if viewStore.state.isLoading {
                        ProgressView()
                    } else {
                        if let selectedVehicle = viewStore.state.selectedVehicle {
                            NavigationStack {
                                VehicleOverviewView(store: .init(
                                    initialState: VehicleOverview.State(selectedVehicleBasic: selectedVehicle),
                                    reducer: VehicleOverview()
                                        .dependency(\.vehiclesDataNetworkClient, .previewValue)
                                ))
                            }
                        } else {
                            VehiclesListView(store: .init(initialState: .init(), reducer: VehiclesList()))
                        }
                    }
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
