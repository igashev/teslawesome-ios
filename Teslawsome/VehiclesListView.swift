//
//  VehiclesListView.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 6.10.22.
//

import SwiftUI
import ComposableArchitecture
import VehiclesModels
import VehiclesNetworking

struct VehiclesListState: Equatable {
    var vehicles: [Vehicle] = []
}

enum VehiclesListAction {
    case didAppear
    case didReceiveVehiclesResponse(TaskResult<VehiclesResponse>)
}

struct VehiclesListEnvironment {
    let getVehicles: () async throws -> VehiclesResponse
    
    static var live: Self {
        .init(getVehicles: {
            let token = CachingClient.live.getToken()!
            return try await VehiclesNetworkClient.live.getVehicles(token: token.accessToken)
        })
    }
    
    static var stub: Self {
        .init(getVehicles: { .stub })
    }
}

var vehiclesListReducer: Reducer<VehiclesListState, VehiclesListAction, VehiclesListEnvironment> {
    .init { state, action, environment in
        switch action {
        case .didAppear:
            return .task {
                let vehiclesResponseTask = await TaskResult {
                    try await environment.getVehicles()
                }
                
                return .didReceiveVehiclesResponse(vehiclesResponseTask)
            }
        case .didReceiveVehiclesResponse(.success(let response)):
            state.vehicles = response.response
            return .none
        case .didReceiveVehiclesResponse(.failure(let error)):
            print(error)
            return .none
        }
    }
}

struct VehiclesListView: View {
    let store: Store<VehiclesListState, VehiclesListAction>
    @ObservedObject private var viewStore: ViewStore<VehiclesListState, VehiclesListAction>
    
    init(store: Store<VehiclesListState, VehiclesListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        List {
            ForEach(viewStore.vehicles) { vehicle in
                VStack(alignment: .leading) {
                    Text(vehicle.displayName)
                    Text(vehicle.vin)
                        .font(.caption)
                }
                
            }
        }
        .onAppear {
            viewStore.send(.didAppear)
        }
    }
}

struct VehiclesListView_Previews: PreviewProvider {
    static var previews: some View {
        VehiclesListView(store: .init(
            initialState: .init(),
            reducer: vehiclesListReducer,
            environment: .stub)
        )
    }
}
