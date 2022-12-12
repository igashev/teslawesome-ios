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

struct VehiclesList: ReducerProtocol {
    struct State: Equatable {
        @BindableState var selectedVehicle: VehicleBasic? = nil
        var vehicles: [VehicleBasic] = []
    }

    enum Action: BindableAction {
        case didAppear
        case didReceiveVehiclesResponse(TaskResult<VehiclesBasicResponse>)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.vehiclesDataNetworkClient) var vehiclesDataNetworkClient
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .task {
                    let vehiclesResponseTask = await TaskResult {
                        try await vehiclesDataNetworkClient.getVehicles()
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
    }
}

struct VehiclesListView: View {
    @ObservedObject private var viewStore: ViewStoreOf<VehiclesList>
    
    init(store: StoreOf<VehiclesList>) {
        self.viewStore = .init(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationSplitView {
            List(viewStore.vehicles, selection: viewStore.binding(\.$selectedVehicle)) { vehicle in
                NavigationLink(value: vehicle) {
                    VStack(alignment: .leading) {
                        Text(vehicle.displayName)
                        Text(vehicle.vin)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Your vehicles")
        } detail: {
            if let selectedVehicle = viewStore.state.selectedVehicle {
                VehicleOverviewView(store: .init(
                    initialState: .init(selectedVehicleBasic: selectedVehicle),
                    reducer: VehicleOverview()
                        .dependency(\.vehiclesDataNetworkClient, .previewValue)
                        .dependency(\.vehicleCommandsNetworkClient, .previewValue)
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
            reducer: VehiclesList())
        )
    }
}
