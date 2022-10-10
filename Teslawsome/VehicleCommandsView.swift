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
    let commands: [VehicleCommand] = VehicleCommand.Kind.allCases.map(VehicleCommand.init)
    
    let wakeUpMaxRetriesCount = 10
    let wakeUpIntervalBetweenRetriesInSeconds: TimeInterval = 3
    var isVehicleWokenUp = false
}

enum VehicleCommandAction {
    case didAppear
    case wakeUp
    case didWakeUp(TaskResult<VehicleResponse>)
    case runCommand(VehicleCommand.Kind)
    case didReceiveCommandResponse(TaskResult<VehicleCommandContainerResponse>)
}

struct VehicleCommandsEnvironment {
    let vehicleCommandsNetworkClient: VehicleCommandsNetworkClient
    
    static var live: Self {
        .init(vehicleCommandsNetworkClient: .live)
    }
    
    #if DEBUG
    static var stub: Self {
        .init(vehicleCommandsNetworkClient: .stub)
    }
    #endif
}

var vehicleCommandReducer: Reducer<VehicleCommandState, VehicleCommandAction, VehicleCommandsEnvironment> {
    .init { state, action, environment in
        switch action {
        case .didAppear:
            return Effect(value: .wakeUp)
        case .wakeUp:
            return .task { [vehicleId = state.vehicle.id, wakeUpAttempts = state.wakeUpMaxRetriesCount, wakeUpAttemptsInterval = state.wakeUpIntervalBetweenRetriesInSeconds] in
                let taskResult = await TaskResult<VehicleResponse> {
                    try await Task.retrying(
                        maxRetryCount: wakeUpAttempts,
                        retryDelayInSeconds: wakeUpAttemptsInterval,
                        retryIf: { $0.response.state != .online },
                        operation: { [vehicleId = vehicleId] in
                            try await environment.vehicleCommandsNetworkClient.wakeUp(vehicleId: vehicleId)
                        }
                    ).value
                }
                
                return .didWakeUp(taskResult)
            }
        case .didWakeUp(.success(let vehicleResponse)):
            state.isVehicleWokenUp = vehicleResponse.response.state == .online
            return .none
        case .didWakeUp(.failure(let error)):
            print(error)
            return .none
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
    .debug()
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
            if viewStore.state.isVehicleWokenUp {
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
            } else {
                VStack {
                    Text("Vehicle is waking up...")
                    ProgressView()
                }
            }
        }
        .onAppear {
            viewStore.send(.didAppear)
        }
    }
}

struct VehicleCommandsView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleCommandsView(store: .init(
            initialState: .init(vehicle: .stub),
            reducer: vehicleCommandReducer,
            environment: .stub
        ))
    }
}
