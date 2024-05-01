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

@Reducer
struct VehiclesList {
    
    @ObservableState
    struct State: Equatable {
        var selectedVehicle: VehicleBasic? = nil
        var vehicles: [VehicleBasic] = []
    }

    enum Action: BindableAction {
        case didAppear
        case didReceiveVehiclesResponse(VehiclesBasicResponse)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.vehiclesDataNetworkClient) var vehiclesDataNetworkClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .run { send in
                    let vehiclesResponseTask = try await vehiclesDataNetworkClient.getVehicles()
                    await send(.didReceiveVehiclesResponse(vehiclesResponseTask))
                }
            case .didReceiveVehiclesResponse(let response):
                state.vehicles = response.response
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct VehiclesListView: View {
    @Bindable var store: StoreOf<VehiclesList>
    
    var body: some View {
        NavigationSplitView {
            List(store.vehicles, selection: $store.selectedVehicle) { vehicle in
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
            if let selectedVehicle = store.selectedVehicle {
                VehicleOverviewView(
                    store: .init(
                        initialState: .init(selectedVehicleBasic: selectedVehicle),
                        reducer: {
                            VehicleOverview()
                                .dependency(\.vehiclesDataNetworkClient, .previewValue)
                                .dependency(\.vehicleCommandsNetworkClient, .previewValue)
                        }
                    )
                )
            } else {
                Text("Pick a vehicle")
            }
        }
        .onAppear {
            store.send(.didAppear)
        }
    }
}

struct VehiclesListView_Previews: PreviewProvider {
    static var previews: some View {
        VehiclesListView(store: .init(
            initialState: .init(),
            reducer: { VehiclesList() })
        )
    }
}
