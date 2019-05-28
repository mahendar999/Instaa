// To parse the JSON, add this file to your project and do:
//
//   let userResponseModel = try UserResponseModel(json)

import Foundation

struct RatingModel{
    let rating: String!
    let count: Int!
    let amount: String!
}

struct UserResponseModel: Codable {
    let success: Int?
    let message: String?
    let result: UserResult?
}

struct UserResult: Codable {
    let id, fullName, address, emailVerified: String?
    let countryCode, authorization, lat, lng: String?
    let city, state, country, postalCode: String?
    let profileImage, userType, isProfileCreated, bio: String?
    let deleted, status: Int?
    let rating, inviteCode, deviceToken, voipDeviceToken, deviceType: String?
    let phoneNumber, email, device, stripeCustomerId, stripeAccountId, defaultCard: String?
    let languages: [UserLanguage]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName = "full_name"
        case address
        case emailVerified = "email_verified"
        case countryCode = "country_code"
        case authorization, lat, lng, city, state, country
        case postalCode = "postal_code"
        case profileImage = "profile_image"
        case userType = "user_type"
        case isProfileCreated = "is_profile_created"
        case bio, deleted, status, rating
        case inviteCode = "invite_code"
        case deviceToken = "device_token"
        case voipDeviceToken = "voip_device_token"
        case deviceType = "device_type"
        case phoneNumber = "phone_number"
        case email, languages, device
        case stripeCustomerId = "stripe_customer_id"
        case stripeAccountId = "stripe_acc_id"
        case defaultCard = "default_card"
    }
}

struct UserLanguage: Codable {
    let id, userID, language: String?
    let status: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "user_id"
        case language, status
    }
}

// MARK: Convenience initializers and mutators

extension UserResponseModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserResponseModel.self, from: data)
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
        result: UserResult?? = nil
        ) -> UserResponseModel {
        return UserResponseModel(
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

extension UserResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserResult.self, from: data)
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
        id: String?? = nil,
        fullName: String?? = nil,
        address: String?? = nil,
        emailVerified: String?? = nil,
        countryCode: String?? = nil,
        authorization: String?? = nil,
        lat: String?? = nil,
        lng: String?? = nil,
        city: String?? = nil,
        state: String?? = nil,
        country: String?? = nil,
        postalCode: String?? = nil,
        profileImage: String?? = nil,
        userType: String?? = nil,
        isProfileCreated: String?? = nil,
        bio: String?? = nil,
        deleted: Int?? = nil,
        status: Int?? = nil,
        rating: String?? = nil,
        inviteCode: String?? = nil,
        deviceToken: String?? = nil,
        voipDeviceToken: String?? = nil,
        deviceType: String?? = nil,
        phoneNumber: String?? = nil,
        email: String?? = nil,
        device: String?? = nil,
        stripeCustomerId: String?? = nil,
        stripeAccountId: String?? = nil,
        defaultCard: String?? = nil,
        languages: [UserLanguage]?? = nil
        ) -> UserResult {
        return UserResult(
            id: id ?? self.id,
            fullName: fullName ?? self.fullName,
            address: address ?? self.address,
            emailVerified: emailVerified ?? self.emailVerified,
            countryCode: countryCode ?? self.countryCode,
            authorization: authorization ?? self.authorization,
            lat: lat ?? self.lat,
            lng: lng ?? self.lng,
            city: city ?? self.city,
            state: state ?? self.state,
            country: country ?? self.country,
            postalCode: postalCode ?? self.postalCode,
            profileImage: profileImage ?? self.profileImage,
            userType: userType ?? self.userType,
            isProfileCreated: isProfileCreated ?? self.isProfileCreated,
            bio: bio ?? self.bio,
            deleted: deleted ?? self.deleted,
            status: status ?? self.status,
            rating: rating ?? self.rating,
            inviteCode: inviteCode ?? self.inviteCode,
            deviceToken: deviceToken ?? self.deviceToken,
            voipDeviceToken: voipDeviceToken ?? self.voipDeviceToken,
            deviceType: deviceType ?? self.deviceType,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            email: email ?? self.email,
            device: device ?? self.device,
            stripeCustomerId: stripeCustomerId ?? self.stripeCustomerId,
            stripeAccountId: stripeAccountId ?? self.stripeAccountId,
            defaultCard: defaultCard ?? self.defaultCard,
            languages: languages ?? self.languages
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension UserLanguage {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserLanguage.self, from: data)
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
        id: String?? = nil,
        userID: String?? = nil,
        language: String?? = nil,
        status: Int?? = nil
        ) -> UserLanguage {
        return UserLanguage(
            id: id ?? self.id,
            userID: userID ?? self.userID,
            language: language ?? self.language,
            status: status ?? self.status
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
