//
//  VehicleCommandsView.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 9.10.22.
//

import SwiftUI
import ComposableArchitecture
import VehicleCommandsNetworking
import VehicleCommandsModels
import VehiclesDataModels

struct VehicleCommandsFeature: ReducerProtocol {
    struct State: Equatable {
        let vehicleId: Int
        let commands: [VehicleCommand] = VehicleCommand.allCases
        let quickActionsCommands: [VehicleCommand] = [.actuateFrunk, .actuateTrunk, .flashLights, .honkHorn]
        
        let wakeUpMaxRetriesCount = 10
        let wakeUpIntervalBetweenRetriesInSeconds: TimeInterval = 3
        var isVehicleWokenUp = false
    }

    enum Action {
        case didAppear
        case wakeUp
        case didWakeUp(TaskResult<VehicleContainerResponse<VehicleBasic>>)
        case runCommand(VehicleCommand)
        case didReceiveCommandResponse(TaskResult<VehicleCommandContainerResponse>)
    }
    
    @Dependency(\.vehicleCommandsNetworkClient) var vehicleCommandsNetworkClient
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didAppear:
            return Effect(value: .wakeUp)
        case .wakeUp:
            return .task { [
                vehicleId = state.vehicleId,
                wakeUpAttempts = state.wakeUpMaxRetriesCount,
                wakeUpAttemptsInterval = state.wakeUpIntervalBetweenRetriesInSeconds
            ] in
                let taskResult = await TaskResult<VehicleContainerResponse<VehicleBasic>> {
                    try await Task.retrying(
                        maxRetryCount: wakeUpAttempts,
                        retryDelayInSeconds: wakeUpAttemptsInterval,
                        retryIf: { $0.response.state != .online },
                        operation: { [vehicleId = vehicleId] in
                            try await vehicleCommandsNetworkClient.wakeUp(vehicleId: vehicleId)
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
        case .didReceiveCommandResponse(.success(let response)):
            print(response)
            return .none
        case .didReceiveCommandResponse(.failure(let error)):
            print(error)
            return .none
        case .runCommand(.honkHorn):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    try await vehicleCommandsNetworkClient.honkHorn(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.flashLights):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.flashLights(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.actuateFrunk):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.actuateTrunk(
                        vehicleId: vehicleId,
                        whichTrunk: .front
                    )
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.actuateTrunk):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.actuateTrunk(
                        vehicleId: vehicleId,
                        whichTrunk: .rear
                    )
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.unlockDoors):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.unlockDoors(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.lockDoors):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.lockDoors(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.ventWindows):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.ventWindows(vehicleId: vehicleId)
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        case .runCommand(.closeWindows):
            return .task { [vehicleId = state.vehicleId] in
                let taskResult = await TaskResult {
                    return try await vehicleCommandsNetworkClient.closeWindows(
                        vehicleId: vehicleId,
                        latitude: 42.6977,
                        longitude: 23.3219
                    )
                }
                
                return .didReceiveCommandResponse(taskResult)
            }
        }
    }
}

struct VehicleCommandsView: View {
    @ObservedObject var viewStore: ViewStoreOf<VehicleCommandsFeature>
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let columns: [GridItem] = .init(
        repeating: .init(.flexible(), alignment: .top),
        count: 5
    )
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    init(store: StoreOf<VehicleCommandsFeature>) {
        self.viewStore = .init(store, observe: { $0 })
    }
    
    var body: some View {
        Group {
            if isLandscape {
                HStack(spacing: 20) {
                    ForEach(viewStore.state.quickActionsCommands) { command in
                        Button(
                            action: {
                                viewStore.send(.runCommand(command))
                            },
                            label: {
                                VStack {
                                    Image(systemName: command.systemImage)
                                    Text(String(describing: command))
                                }
                                .frame(maxWidth: .infinity)
                                .font(.largeTitle)
                            }
                        )
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                ScrollView {
                    if viewStore.state.isVehicleWokenUp {
                        LazyVGrid(columns: columns, spacing: 25) {
                            ForEach(viewStore.commands) { command in
                                Button(
                                    action: {
                                        viewStore.send(.runCommand(command))
                                    },
                                    label: {
                                        VStack() {
                                            Image(systemName: command.systemImage)
                                                .font(.title)
                                            Text(String(describing: command))
                                                .font(.caption)
                                        }
                                    }
                                )
                            }
                        }
                    } else {
                        VStack {
                            Text("Vehicle is waking up...")
                            ProgressView()
                        }
                    }
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
            initialState: .init(vehicleId: VehicleBasic.stub.id),
            reducer: VehicleCommandsFeature())
        )
    }
}
