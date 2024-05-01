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

@Reducer
struct VehicleCommandsFeature {
    @ObservableState
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
        case didWakeUp(VehicleContainerResponse<VehicleBasic>)
        case runCommand(VehicleCommand)
        case didReceiveCommandResponse(VehicleCommandContainerResponse)
    }
    
    @Dependency(\.vehicleCommandsNetworkClient) var vehicleCommandsNetworkClient
    
    var body: some ReducerOf<VehicleCommandsFeature> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                return wakeUp(
                    vehicleId: state.vehicleId,
                    wakeUpAttempts: state.wakeUpMaxRetriesCount,
                    wakeUpAttemptsInterval: state.wakeUpIntervalBetweenRetriesInSeconds
                )
            case .didWakeUp(let vehicleResponse):
                state.isVehicleWokenUp = vehicleResponse.response.state == .online
                return .none
            case .didReceiveCommandResponse(let response):
                print(response)
                return .none
            case .runCommand(.honkHorn):
                return .run { [vehicleId = state.vehicleId] send in
                    let result = try await vehicleCommandsNetworkClient.honkHorn(vehicleId: vehicleId)
                    await send(.didReceiveCommandResponse(result))
                }
            case .runCommand(.flashLights):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.flashLights(vehicleId: vehicleId)
                    await send(.didReceiveCommandResponse(taskResult))
                }
            case .runCommand(.actuateFrunk):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.actuateTrunk(
                        vehicleId: vehicleId,
                        whichTrunk: .front
                    )
                    
                    await send(.didReceiveCommandResponse(taskResult))
                }
            case .runCommand(.actuateTrunk):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.actuateTrunk(
                        vehicleId: vehicleId,
                        whichTrunk: .rear
                    )
                    
                    await send(.didReceiveCommandResponse(taskResult))
                }
            case .runCommand(.unlockDoors):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.unlockDoors(vehicleId: vehicleId)
                    await send(.didReceiveCommandResponse(taskResult))
                }
            case .runCommand(.lockDoors):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.lockDoors(vehicleId: vehicleId)
                    await send(.didReceiveCommandResponse(taskResult))
                }
            case .runCommand(.ventWindows):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.ventWindows(vehicleId: vehicleId)
                    await send(.didReceiveCommandResponse(taskResult))
                }
            case .runCommand(.closeWindows):
                return .run { [vehicleId = state.vehicleId] send in
                    let taskResult = try await vehicleCommandsNetworkClient.closeWindows(
                        vehicleId: vehicleId,
                        latitude: 42.6977,
                        longitude: 23.3219
                    )
                    
                    await send(.didReceiveCommandResponse(taskResult))
                }
            }
        }
    }
    
    private func wakeUp(
        vehicleId: Int,
        wakeUpAttempts: Int,
        wakeUpAttemptsInterval: TimeInterval
    ) -> Effect<Action> {
        return .run { send in
            let response: VehicleContainerResponse<VehicleBasic> = try await Task.retrying(
                maxRetryCount: wakeUpAttempts,
                retryDelayInSeconds: wakeUpAttemptsInterval,
                retryIf: { $0.response.state != .online },
                operation: { [vehicleId = vehicleId] in
                    try await vehicleCommandsNetworkClient.wakeUp(vehicleId: vehicleId)
                }
            ).value
            
            await send(.didWakeUp(response))
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
        VehicleCommandsView(store: .init(initialState: .init(vehicleId: 0), reducer: {
            VehicleCommandsFeature()
        }))
    }
}
