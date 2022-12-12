public struct VehicleFull: Decodable, Equatable {
    public let id: Int
    public let vehicleId: Int
    public let vin: String
    public let displayName: String
    public let color: String?
    public let tokens: [String]
    public var state: VehicleStateType
    public let inService: Bool
    public let calendarEnabled: Bool
    public let apiVersion: Int
    public let driveState: DriveState
    public let climateState: ClimateState
    public let chargeState: ChargeState
    public let guiSettings: GUISettings
    public let vehicleState: VehicleState
    public let vehicleConfig: VehicleConfig
}

public struct DriveState: Decodable, Equatable {
    public let gpsAsOf: Double
    public let heading: Int
    public let latitude: Double
    public let longitude: Double
    public let power: Int
    public let shiftState: String?
    public let speed: Double?
    public let timestamp: Double
}

public struct ClimateState: Decodable, Equatable {
    public let batteryHeater: Bool
    public let driverTempSetting: Double
    public let insideTemp: Double
    public let isClimateOn: Bool
    public let isPreconditioning: Bool
    public let outsideTemp: Double
    public let wiperBladeHeater: Bool
}

public struct ChargeState: Decodable, Equatable {
    public enum State: String, Decodable, CustomStringConvertible {
        case disconnected = "Disconnected"
        case charging = "Charging"
        case stopped = "Stopped"
        
        public var description: String { rawValue }
    }
    
    public let batteryHeaterOn: Bool
    public let batteryLevel: Int
    public let batteryRange: Double
    public let chargeRate: Double
    public let chargingState: State
    public let minutesToFullCharge: Int
    public let timeToFullCharge: Double
}

public struct GUISettings: Decodable, Equatable {
    enum CodingKeys: String, CodingKey {
        case is24HourTime = "gui24HourTime"
        case temperatureUnit = "guiTemperatureUnits"
        case chargeRateUnit = "guiChargeRateUnits"
        case distanceUnit = "guiDistanceUnits"
        case tirePressureUnit = "guiTirepressureUnits"
        case showRangeUnits
        case timestamp
    }
    public enum TemperatureUnit: String, Decodable {
        case celcius = "C"
        case farenheit = "F"
    }
    
    public enum DistanceUnit: String, Decodable {
        case miles = "mi/hr"
        case kilometers = "km/hr"
    }
    
    public enum ChargeRateUnit: String, Decodable {
        case miles = "mi/hr"
        case kilometers = "km/hr"
        case kW
    }
    
    public enum TirePressureUnit: String, Decodable {
        case psi = "PSI"
        case bar = "Bar"
    }
    
    public let is24HourTime: Bool
    public let temperatureUnit: TemperatureUnit
    public let chargeRateUnit: ChargeRateUnit
    public let distanceUnit: DistanceUnit
    public let tirePressureUnit: TirePressureUnit
    public let showRangeUnits: Bool
    public let timestamp: Double
}

public struct VehicleConfig: Decodable, Equatable {
    public enum CarType: String, Decodable {
        case modelS = "models"
        case modelSPlaid = "models2"
        case model3 = "model3"
        case modelX = "modelx"
        case modelXPlaid = "modelx2"
        case modelY = "modely"
    }
    
    public let carType: CarType
    public let euVehicle: Bool
    public let chargePortType: String
    public let exteriorColor: String
    public let exteriorTrim: String
    public let hasAirSuspension: Bool
    public let hasLudicrousMode: Bool
    public let hasSeatCooling: Bool
    public let utcOffset: Int
}

public struct VehicleState: Decodable, Equatable {
    enum CodingKeys: String, CodingKey {
        case vehicleName, locked, odometer, sentryMode
        case driverFront = "df"
        case driverRear = "dr"
        case passengerFront = "pf"
        case passengerRear = "pr"
        case frontTrunk = "ft"
        case rearTrunk = "rt"
    }
    
    public let vehicleName: String?
    public let locked: Bool
    public let odometer: Double
    public let driverFront: Int
    public let driverRear: Int
    public let passengerFront: Int
    public let passengerRear: Int
    public let frontTrunk: Int
    public let rearTrunk: Int
    public let sentryMode: Bool
}
