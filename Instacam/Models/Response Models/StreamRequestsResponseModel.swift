// To parse the JSON, add this file to your project and do:
//
//   let streamRequestsResponseModel = try StreamRequestsResponseModel(json)

import Foundation

struct StreamRequestsResponseModel: Codable {
    let success: Int?
    let message: String?
    let result: [StreamRequestsResult]?
}

struct StreamRequestsResult: Codable {
    let userID: [String]?
    let location, lat, lng, description: String?
    let duration, price: String?
    let streamerID: [String]?
    let status, totalDuration: Int?
    let id, uid: String?
    let viewerName, channelName, created, acceptedTimestamp, cancelledTimestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case location, lat, lng, description, duration, price
        case streamerID = "streamer_id"
        case status, created
        case id = "_id"
        case viewerName = "viewer_name"
        case channelName = "channel_name"
        case acceptedTimestamp = "first_call_timestamp"
        case cancelledTimestamp = "cancelled_timestamp"
        case totalDuration = "total_duration"
        case uid
    }
}

// MARK: Convenience initializers and mutators

extension StreamRequestsResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(StreamRequestsResponseModel.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        success: Int?? = nil,
        message: String?? = nil,
        result: [StreamRequestsResult]?? = nil
        ) -> StreamRequestsResponseModel {
        return StreamRequestsResponseModel(
            success: success ?? self.success,
            message: message ?? self.message,
            result: result ?? self.result
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

fileprivate func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

fileprivate func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
