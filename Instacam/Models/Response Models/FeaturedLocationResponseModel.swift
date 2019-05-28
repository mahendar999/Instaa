// To parse the JSON, add this file to your project and do:
//
//   let requestStreamResponseModel = try RequestStreamResponseModel(json)

import Foundation

struct FeaturedLocationResponseModel: Codable {
    let success: Int?
    let message: String?
    let result: [FeaturedLocationResult]?
}

struct FeaturedLocationResult: Codable {
    let address, lat, lng, name, image, created: String?
    let status: Int?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case address, lat, lng, name, image, created
        case status
        case id = "_id"
    }
}

// MARK: Convenience initializers and mutators

extension FeaturedLocationResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FeaturedLocationResponseModel.self, from: data)
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
        result: [FeaturedLocationResult]?? = nil
        ) -> FeaturedLocationResponseModel {
        return FeaturedLocationResponseModel(
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
