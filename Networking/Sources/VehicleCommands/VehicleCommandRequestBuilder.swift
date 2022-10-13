import Networking
import NetworkRequester
import VehicleCommandsModels

enum RequestBuilder {
    static func makeWakeUp(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.wakeUp(vehicleId: vehicleId), httpMethod: .post)
    }
    
    static func makeHonkHorn(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.honkHorn(vehicleId: vehicleId), httpMethod: .post)
    }
    
    static func makeFlashLights(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.flashLights(vehicleId: vehicleId), httpMethod: .post)
    }
    
    static func makeActuateTrunk(vehicleId: Int, whichTrunk: WhichTrunk) -> URLRequestBuilder {
        .api(
            endpoint: Endpoint.actuateTrunk(vehicleId: vehicleId),
            httpMethod: .post,
            httpBody: .init(encodable: WhichTrunkRequest(whichTrunk: whichTrunk))
        )
    }
    
    static func makeDoorsUnlock(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.doorUnlock(vehicleId: vehicleId), httpMethod: .post)
    }
    
    static func makeDoorsLock(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.doorLock(vehicleId: vehicleId), httpMethod: .post)
    }
    
    static func makeWindowControl(
        vehicleId: Int,
        command: WindowControlCommand,
        latitude: Double?,
        longitude: Double?
    ) -> URLRequestBuilder {
        .api(
            endpoint: Endpoint.windowControl(vehicleId: vehicleId),
            httpMethod: .post,
            httpBody: .init(encodable: WindowControlRequest(
                command: command,
                latitude: latitude,
                longitude: longitude
            ))
        )
    }
}

struct WindowControlRequest: Encodable {
    enum CodingKeys: String, CodingKey {
        case command
        case latitude = "lat"
        case longitude = "lon"
    }
    
    let command: WindowControlCommand
    let latitude: Double?
    let longitude: Double?
}
