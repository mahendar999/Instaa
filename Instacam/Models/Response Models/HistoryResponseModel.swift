// To parse the JSON, add this file to your project and do:
//
//   let historyResponseModel = try HistoryResponseModel(json)

import Foundation

struct HistoryResponseModel: Codable {
    let success: Int?
    let message: String?
    let result: [HistoryResult]?
}

struct HistoryResult: Codable {
    let userID: [HistoryUserData]?
    let location, lat, lng, description: String?
    let duration, channelName, price: String?
    let streamerID: [HistoryUserData]?
    let viewerRating, viewerCompliment, viewerComplaint, streamerRating: String?
    let streamerCompliment, streamerComplaint, streamerTip: String?
    let totalDuration, status: Int?
    let acceptedTimestamp, updatedAt, cancelledTimestamp, id, finalPrice, finalDuration: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case location, lat, lng, description, duration
        case channelName = "channel_name"
        case price
        case streamerID = "streamer_id"
        case viewerRating = "viewer_rating"
        case viewerCompliment = "viewer_compliment"
        case viewerComplaint = "viewer_complaint"
        case streamerRating = "streamer_rating"
        case streamerCompliment = "streamer_compliment"
        case streamerComplaint = "streamer_complaint"
        case streamerTip = "streamer_tip"
        case totalDuration = "total_duration"
        case status
        case acceptedTimestamp = "first_call_timestamp"
        case updatedAt = "updatedAt"
        case cancelledTimestamp = "cancelled_timestamp"
        case finalPrice = "final_price"
        case finalDuration = "final_duration"
        case id = "_id"
    }
}

struct HistoryUserData: Codable {
    let fullName, id, profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case id = "_id"
        case profileImage = "profile_image"
    }
}

// MARK: Convenience initializers and mutators

extension HistoryResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(HistoryResponseModel.self, from: data)
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
        result: [HistoryResult]?? = nil
        ) -> HistoryResponseModel {
        return HistoryResponseModel(
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
