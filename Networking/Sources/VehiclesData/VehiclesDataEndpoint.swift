import protocol NetworkRequester.URLProviding

enum Endpoint: URLProviding {
    case vehicles
    case vehicleData(vehicleId: Int)
    
    var url: String {
        switch self {
        case .vehicles:
            return "api/1/vehicles"
        case .vehicleData(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/vehicle_data"
        }
    }
}
