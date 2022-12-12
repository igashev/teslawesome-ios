//
//  VehicleCommandExtension.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 6.11.22.
//

import VehicleCommandsModels

extension VehicleCommand {
    var systemImage: String {
        switch self {
        case .honkHorn:
            return "megaphone.fill"
        case .flashLights:
            return "flashlight.on.fill"
        case .actuateFrunk:
            return "rectangle.roundedtop.fill"
        case .actuateTrunk:
            return "rectangle.roundedbottom.fill"
        case .unlockDoors:
            return "lock.open.fill"
        case .lockDoors:
            return "lock.fill"
        case .ventWindows:
            return "rectangle"
        case .closeWindows:
            return "rectangle.fill"
        }
    }
}
