//
//  VehicleCommandsView.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 9.10.22.
//

import SwiftUI
import ComposableArchitecture
import VehicleCommandsNetworking
import VehiclesDataModels

struct VehicleCommandState: Equatable {
    let vehicle: Vehicle
    let commands: [VehicleCommand] = [
        .init(kind: .honkHorn),
        .init(kind: .flashLights)
    ]
}

enum VehicleCommandAction {
    case runCommand(VehicleCommand.Kind)
    case didReceiveCommandResponse(TaskResult<VehicleCommandContainerResponse>)
}

struct VehicleCommandsEnvironment {
    let vehicleCommandsNetworkClient: VehicleCommandsNetworkClient
    
    static var live: Self {
        .init(vehicleCommandsNetworkClient: .live)
    }
}

var vehicleCommandReducer: Reducer<VehicleCommandState, VehicleCommandAction, VehicleCommandsEnvironment> {
    .init { state, action, environment in
        switch action {
        case .runCommand(.honkHorn):
            return .task { [vehicleId = state.vehicle.id] in
                let taskResult = await TaskResult {
                    try await environment.vehicleCommandsNetworkClient.honkHorn(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.flashLights):
            return .task { [vehicleId = state.vehicle.id] in
                let taskResult = await TaskResult {
                    return try await environment.vehicleCommandsNetworkClient.flashLights(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .didReceiveCommandResponse(.success(let response)):
            print(response)
            return .none
        case .didReceiveCommandResponse(.failure(let error)):
            print(error)
            return .none
        }
    }
}

struct VehicleCommandsView: View {
    let store: Store<VehicleCommandState, VehicleCommandAction>
    @ObservedObject var viewStore: ViewStore<VehicleCommandState, VehicleCommandAction>
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(store: Store<VehicleCommandState, VehicleCommandAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(viewStore.commands, id: \.kind) { command in
                    Button(
                        action: {
                            viewStore.send(.runCommand(command.kind))
                        },
                        label: {
                            VStack {
                                Image(systemName: "hand.wave")
                                Text(String(describing: command.kind))
                            }
                        }
                    )
                    .font(.largeTitle)
                }
            }
        }
    }
}

struct VehicleCommandsView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleCommandsView(store: .init(
            initialState: .init(vehicle: .stub),
            reducer: vehicleCommandReducer,
            environment: .live
        ))
    }
}
