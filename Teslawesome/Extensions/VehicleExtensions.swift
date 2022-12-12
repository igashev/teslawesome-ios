//
//  VehicleExtensions.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 27.10.22.
//

import Foundation
import VehiclesDataModels

extension VehicleFull {
    var chargeRateInUserPreferedUnit: Double {
        switch guiSettings.chargeRateUnit {
        case .miles, .kW:
            return chargeState.chargeRate
        case .kilometers:
            let miles = Measurement(value: chargeState.chargeRate, unit: UnitLength.miles)
            return miles.converted(to: UnitLength.kilometers).value
        }
    }
    
    var batteryRangeInUserPreferedUnit: Double {
        getRange(chargeState.batteryRange, inUserPreferedUnit: guiSettings.distanceUnit)
    }
    
    private func getRange(_ range: Double, inUserPreferedUnit unit: GUISettings.DistanceUnit) -> Double {
        switch unit {
        case .miles:
            return range
        case .kilometers:
            let miles = Measurement(value: range, unit: UnitLength.miles)
            return miles.converted(to: UnitLength.kilometers).value
        }
    }
}

extension VehicleStateType {
    var systemImage: String {
        switch self {
        case .online:
            return "sun.max.fill"
        case .asleep:
            return "powersleep"
        }
    }
}

extension ChargeState.State {
    var systemImage: String {
        switch self {
        case .charging:
            return "bolt.fill"
        case .disconnected:
            return "bolt.slash"
        case .stopped:
            return "stop.fill"
        }
    }
}
