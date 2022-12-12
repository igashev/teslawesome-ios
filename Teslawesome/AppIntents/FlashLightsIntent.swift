//
//  FlashLightsIntent.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 13.10.22.
//

import Foundation
import AppIntents
import VehicleCommandsNetworking

struct FlashLightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Flash Tesla lights"
    
    func perform() async throws -> some IntentResult  {
//        _ = try await Task.retrying(
//            maxRetryCount: 10,
//            retryDelayInSeconds: 3,
//            retryIf: { $0.response.state != .online },
//            operation: {
//                try await VehicleCommandsNetworkClient.liveValue.wakeUp(vehicleId: 929754369671265)
//            }
//        ).value
        
        _ = try await VehicleCommandsNetworkClient.liveValue.wakeUp(vehicleId: 929754369671265)
        _ = try await VehicleCommandsNetworkClient.liveValue.flashLights(vehicleId: 929754369671265)
        return .result()
    }
    
    static var openAppWhenRun: Bool = true
}

struct OpenTrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Open the trunk"
    
    func perform() async throws -> some IntentResult  {
        _ = try await Task.retrying(
            maxRetryCount: 10,
            retryDelayInSeconds: 3,
            retryIf: { $0.response.state != .online },
            operation: {
                try await VehicleCommandsNetworkClient.liveValue.wakeUp(vehicleId: 929754369671265)
            }
        ).value
        
        _ = try await VehicleCommandsNetworkClient.liveValue.actuateTrunk(vehicleId: 929754369671265, whichTrunk: .rear)
        return .result()
    }
}

struct TeslaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        print(AppShortcutPhraseToken.applicationName)
        return [
            .init(
                intent: FlashLightsIntent(),
                phrases: ["car lights", "Tesla lights on"],
                shortTitle: "Cool stuff",
                systemImageName: "pencil"
            )
        ]
    }
}
