//
//  VehicleOverviewView.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 19.10.22.
//

import SwiftUI
import ComposableArchitecture
import VehiclesDataModels
import MapKit

@Reducer
struct VehicleOverview {
    struct State: Equatable {
        let selectedVehicleBasic: VehicleBasic
        
        fileprivate(set) var vehicleCommandsState: VehicleCommandsFeature.State
        fileprivate(set) var vehicle: VehicleFull? = nil
        
        init(selectedVehicleBasic: VehicleBasic) {
            self.vehicleCommandsState = .init(vehicleId: selectedVehicleBasic.id)
            self.selectedVehicleBasic = selectedVehicleBasic
        }
    }
    
    enum Action {
        case didAppear
        case didReceiveVehicle(response: VehicleFull)
        case vehicleCommands(VehicleCommandsFeature.Action)
        case didRotateDevice(isLandscape: Bool)
    }
    
    @Dependency(\.vehiclesDataNetworkClient) var vehiclesDataNetworkClient
    
    var body: some ReducerOf<VehicleOverview> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .run { [vehicleId = state.selectedVehicleBasic.id] send in
                    let vehicleData = try await vehiclesDataNetworkClient.getVehicleData(vehicleId: vehicleId).response
                    await send(.didReceiveVehicle(response: vehicleData))
                }
            case .didReceiveVehicle(let vehicle):
                state.vehicle = vehicle
                return .none
            case .vehicleCommands(.didWakeUp(let vehicleResponse)):
                state.vehicle?.state = vehicleResponse.response.state
                return .none
            default:
                return .none
            }
        }
        
        Scope(state: \.vehicleCommandsState, action: /Action.vehicleCommands) {
            VehicleCommandsFeature()
                .dependency(\.vehicleCommandsNetworkClient, .previewValue)
        }
    }
}

struct VehicleOverviewView: View {
    let store: StoreOf<VehicleOverview>
    @ObservedObject var viewStore: ViewStoreOf<VehicleOverview>
    
    init(store: StoreOf<VehicleOverview>) {
        self.store = store
        self.viewStore = .init(store, observe: { $0 })
    }
    
    var body: some View {
        ScrollView {
            if let vehicle = viewStore.state.vehicle {
                VStack(spacing: 10) {
                    Image(systemName: "bolt.car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                    
                    Label(String(describing: vehicle.state), systemImage: vehicle.state.systemImage)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    ProgressView(
                        value: Double(vehicle.chargeState.batteryLevel),
                        total: 100,
                        label: {
                            HStack {
                                Text("Battery level")
                                Spacer()
                                Label(String(describing: vehicle.chargeState.chargingState), systemImage: vehicle.chargeState.chargingState.systemImage)
                                    .foregroundColor(.secondary)
                            }
                        },
                        currentValueLabel: {
                            HStack {
                                Text("\(vehicle.chargeState.batteryLevel)%")
                                Spacer()
                                Text("\(vehicle.batteryRangeInUserPreferedUnit, specifier: "%.2f") \(String(describing: vehicle.guiSettings.distanceUnit))")
                            }
                        }
                    )
                    .tint(chargingLevelColor(chargingLevel: vehicle.chargeState.batteryLevel))
                    // 42.721742, 23.268204
                    Map(
                        coordinateRegion: .constant(
                            .init(
                                center: .init(latitude: 42.721742, longitude: 23.268204),
                                latitudinalMeters: 250,
                                longitudinalMeters: 250
                            )
                        )
                    )
                    .frame(maxWidth: .infinity, minHeight: 250)
                    .edgesIgnoringSafeArea(.horizontal)
                    .disabled(true)

                    Spacer()
                }
                .padding(.horizontal)
                .bottomSheet(
                    isPresented: .constant(true),
                    presentationDetents: [.height(75), .medium, .large],
                    largestUndimmedIdentifier: .large,
                    interactiveDismissDisabled: true
                ) {
                    VehicleCommandsView(
                        store: store.scope(
                            state: \.vehicleCommandsState,
                            action: \.vehicleCommands
                        )
                    )
                    .padding(.top, 25)
                }
            } else {
                VStack {
                    Text("Getting full info for your vehicle...")
                    ProgressView()
                }
            }
        }
        .navigationTitle(viewStore.state.selectedVehicleBasic.displayName)
        .onAppear {
            viewStore.send(.didAppear)
        }
    }
    
    private func chargingLevelColor(chargingLevel: Int) -> Color {
        switch chargingLevel {
        case 0..<20:
            return .red
        case 20...100:
            return .green
        default:
            return .secondary
        }
    }
}

struct VehicleOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VehicleOverviewView(store: .init(
                initialState: .init(selectedVehicleBasic: .stub),
                reducer: { VehicleOverview() })
            )
        }
    }
}
