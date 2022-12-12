import protocol NetworkRequester.URLProviding

enum Endpoint: URLProviding {
    case openChargePort(vehicleId: Int), closeChargePort(vehicleId: Int)
    case startCharge(vehicleId: Int), stopCharge(vehicleId: Int)
    case chargeStandard(vehicleId: Int), chargeMaxRange(vehicleId: Int), chargeLimit(vehicleId: Int), chargeAmps(vehicleId: Int)
    case scheduledCharging(vehicleId: Int), scheduledDeparture(vehicleId: Int)
    
    var url: String {
        switch self {
        case .openChargePort(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/charge_port_door_open"
        case .closeChargePort(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/charge_port_door_close"
        case .startCharge(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/charge_start"
        case .stopCharge(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/charge_stop"
        case .chargeStandard(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/charge_standard"
        case .chargeMaxRange(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/charge_max_range"
        case .chargeLimit(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/set_charge_limit"
        case .chargeAmps(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/set_charging_amps"
        case .scheduledCharging(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/set_scheduled_charging"
        case .scheduledDeparture(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/set_scheduled_departure"
        }
    }
}
