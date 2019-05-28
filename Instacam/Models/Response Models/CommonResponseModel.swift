// To parse the JSON, add this file to your project and do:
//
//   let userResponseModel = try CommonResponseModel(json)

import Foundation

// MARK:- COmmon Model

struct CommonResponseModel: Codable {
    let success: Int?
    let message: String?
    let data: String?
}

extension CommonResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CommonResponseModel.self, from: data)
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
        data: String?? = nil
        ) -> CommonResponseModel {
        return CommonResponseModel(
            success: success ?? self.success,
            message: message ?? self.message,
            data: data ?? self.data
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK:-

struct NotificationResponseModel: Codable {
    let success: Int?
    let message: String?
    let acceptedTimestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case acceptedTimestamp = "first_call_timestamp"
    }
}

extension NotificationResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NotificationResponseModel.self, from: data)
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
        acceptedTimestamp: String?? = nil
        ) -> NotificationResponseModel {
        return NotificationResponseModel(
            success: success ?? self.success,
            message: message ?? self.message,
            acceptedTimestamp: acceptedTimestamp ?? self.acceptedTimestamp
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

struct RatingResponseModel: Codable {
    let success: Int?
    let message: String?
    let rating: String!
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case rating, count
    }
}

extension RatingResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RatingResponseModel.self, from: data)
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
        rating: String?? = nil,
        count: Int?? = nil
        ) -> RatingResponseModel {
        return RatingResponseModel(
            success: success ?? self.success,
            message: message ?? self.message,
            rating: rating ?? self.rating,
            count: count ?? self.count
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
