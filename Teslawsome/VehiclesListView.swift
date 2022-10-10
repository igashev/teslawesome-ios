//
//  VehiclesListView.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 6.10.22.
//

import SwiftUI
import ComposableArchitecture
import VehiclesDataModels
import VehiclesDataNetworking

struct VehiclesListState: Equatable {
    @BindableState var selectedVehicle: Vehicle? = nil
    var vehicles: [Vehicle] = []
}

enum VehiclesListAction: BindableAction {
    case didAppear
    case didReceiveVehiclesResponse(TaskResult<VehiclesResponse>)
    case binding(BindingAction<VehiclesListState>)
}

struct VehiclesListEnvironment {
    let getVehicles: () async throws -> VehiclesResponse
    
    static var live: Self {
        .init(getVehicles: { try await VehiclesDataNetworkClient.live.getVehicles() })
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
        case .binding:
            return .none
        }
    }
    .binding()
}

struct VehiclesListView: View {
    let store: Store<VehiclesListState, VehiclesListAction>
    @ObservedObject private var viewStore: ViewStore<VehiclesListState, VehiclesListAction>
    
    init(store: Store<VehiclesListState, VehiclesListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        NavigationSplitView {
            List(viewStore.vehicles, id: \.self, selection: viewStore.binding(\.$selectedVehicle)) { vehicle in
                NavigationLink(value: vehicle) {
                    VStack(alignment: .leading) {
                        Text(vehicle.displayName)
                        Text(vehicle.vin)
                            .font(.caption)
                    }
                }
            }
        } detail: {
            if let selectedVehicle = viewStore.state.selectedVehicle {
                VehicleCommandsView(store: .init(
                    initialState: .init(vehicle: selectedVehicle),
                    reducer: vehicleCommandReducer,
                    environment: .live
                ))
            } else {
                Text("Pick a vehicle")
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
