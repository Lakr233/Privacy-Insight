// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let NDPrivacyAccess = try NDPrivacyAccess(json)

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

public struct NDPrivacySummary {
    let privacyAccess: [NDPrivacyAccess]
    let networkAccess: [NDNetworkAccess]
    let applicationSummary: [String: NDApplicationSummary]
    let beginDate: Date
    let endingDate: Date

    public struct NDApplicationSummary: Equatable, Identifiable {
        public var id = UUID()
        let bundleIdentifier: String
        let reportPrivacyElement: [NDPrivacyAccess]
        let reportNetworkElement: [NDNetworkAccess]
    }

    private class NDApplicationSummaryBuilder {
        let bundleIdentifier: String
        var reportPrivacyElement: [NDPrivacyAccess] = []
        var reportNetworkElement: [NDNetworkAccess] = []

        init(bundleIdentifier: String) {
            self.bundleIdentifier = bundleIdentifier
        }

        func lockdown() -> NDApplicationSummary {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return .init(bundleIdentifier: bundleIdentifier,
                         reportPrivacyElement: reportPrivacyElement
                             .sorted(by: { a, b in
                                 guard let dateA = formatter.date(from: a.timeStamp),
                                       let dateB = formatter.date(from: b.timeStamp)
                                 else {
                                     return false
                                 }
                                 return dateA < dateB
                             }),
                         reportNetworkElement: reportNetworkElement
                             .sorted(by: { a, b in
                                 guard let dateA = formatter.date(from: a.timeStamp),
                                       let dateB = formatter.date(from: b.timeStamp)
                                 else {
                                     return false
                                 }
                                 return dateA < dateB
                             })
            )
        }
    }

    typealias TotalAndCurrent = (Int, Int)
    init(
        privacyAccess: [NDPrivacyAccess],
        networkAccess: [NDNetworkAccess],
        progressUpdate: (TotalAndCurrent) -> Void
    ) {
        var total = privacyAccess.count + networkAccess.count
        self.privacyAccess = privacyAccess
        self.networkAccess = networkAccess
        var constructor: [String: NDApplicationSummaryBuilder] = [:]
        var begin: Date = Date(timeIntervalSince1970: 2147483647000)
        var end: Date = Date(timeIntervalSince1970: 0)
        var complete: Int = 0
        privacyAccess.forEach { access in
            /*
             {
                 "accessor": {
                     "identifier": "com.bytedance.ee.lark",
                     "identifierType": "bundleID"
                 },
                 "category": "camera",
                 "identifier": "6279DD3B-9B63-4ED4-86C8-F2CD0E9E582D",
                 "kind": "intervalBegin",
                 "timeStamp": "2021-09-21T17:08:41.458+08:00",
                 "type": "access"
             }
             */
            let identifier = access.accessor.identifier
            guard identifier.count > 0 else { return }
            let read = constructor[identifier, default: .init(bundleIdentifier: identifier)]
            read.reportPrivacyElement.append(access)
            constructor[identifier] = read
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let currentDate = formatter.date(from: access.timeStamp) {
                if currentDate.timeIntervalSince(begin) < 0 { begin = currentDate }
                if currentDate.timeIntervalSince(end) > 0 { end = currentDate }
            }
            progressUpdate((total, complete))
            complete += 1
        }
        networkAccess.forEach { access in
            /*
             {
                 "domain": "61.174.42.248",
                 "firstTimeStamp": "2021-09-27T00:36:26.432+08:00",
                 "context": "",
                 "timeStamp": "2021-09-27T00:36:26.432+08:00",
                 "domainType": 2,
                 "initiatedType": "AppInitiated",
                 "hits": 1,
                 "type": "networkActivity",
                 "domainOwner": "",
                 "bundleID": "com.nssurge.inc.surge-ios"
             }
             */
            let identifier = access.bundleid
            guard identifier.count > 0 else { return }
            let read = constructor[identifier, default: .init(bundleIdentifier: identifier)]
            read.reportNetworkElement.append(access)
            constructor[identifier] = read
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let currentDate = formatter.date(from: access.timeStamp) {
                if currentDate.timeIntervalSince(begin) < 0 { begin = currentDate }
                if currentDate.timeIntervalSince(end) > 0 { end = currentDate }
            }
            progressUpdate((total, complete))
            complete += 1
        }
        var summaryBuilder = [String: NDApplicationSummary]()
        total = constructor.count
        complete = 0
        for (key, value) in constructor {
            summaryBuilder[key] = value.lockdown()
            complete += 1
            progressUpdate((total, complete))
        }
        applicationSummary = summaryBuilder
        beginDate = begin
        endingDate = end
    }
}

// MARK: - NDPrivacyAccess

public struct NDPrivacyAccess: Codable, Hashable {
    public let accessor: NDAccessor
    public let category: String
    public let identifier: String
    public let kind: String
    public let timeStamp: String
    public let type: String

    enum CodingKeys: String, CodingKey {
        case accessor
        case category
        case identifier
        case kind
        case timeStamp
        case type
    }

    public init(accessor: NDAccessor, category: String, identifier: String, kind: String, timeStamp: String, type: String) {
        self.accessor = accessor
        self.category = category
        self.identifier = identifier
        self.kind = kind
        self.timeStamp = timeStamp
        self.type = type
    }
}

// MARK: NDPrivacyAccess convenience initializers and mutators

public extension NDPrivacyAccess {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NDPrivacyAccess.self, from: data)
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
        accessor: NDAccessor? = nil,
        category: String? = nil,
        identifier: String? = nil,
        kind: String? = nil,
        timeStamp: String? = nil,
        type: String? = nil
    ) -> NDPrivacyAccess {
        return NDPrivacyAccess(
            accessor: accessor ?? self.accessor,
            category: category ?? self.category,
            identifier: identifier ?? self.identifier,
            kind: kind ?? self.kind,
            timeStamp: timeStamp ?? self.timeStamp,
            type: type ?? self.type
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - NDAccessor

public struct NDAccessor: Codable, Hashable {
    public let identifier: String
    public let identifierType: String

    enum CodingKeys: String, CodingKey {
        case identifier
        case identifierType
    }

    public init(identifier: String, identifierType: String) {
        self.identifier = identifier
        self.identifierType = identifierType
    }
}

// MARK: NDAccessor convenience initializers and mutators

public extension NDAccessor {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NDAccessor.self, from: data)
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
        identifier: String? = nil,
        identifierType: String? = nil
    ) -> NDAccessor {
        return NDAccessor(
            identifier: identifier ?? self.identifier,
            identifierType: identifierType ?? self.identifierType
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let NDNetworkAccess = try NDNetworkAccess(json)

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

// MARK: - NDNetworkAccess

public struct NDNetworkAccess: Codable, Hashable {
    public let domain: String
    public let firstTimeStamp: String
    public let context: String
    public let timeStamp: String
    public let domainType: Int
    public let initiatedType: String
    public let hits: Int
    public let type: String
    public let domainOwner: String
    public let bundleid: String

    enum CodingKeys: String, CodingKey {
        case domain
        case firstTimeStamp
        case context
        case timeStamp
        case domainType
        case initiatedType
        case hits
        case type
        case domainOwner
        case bundleid = "bundleID"
    }

    public init(domain: String, firstTimeStamp: String, context: String, timeStamp: String, domainType: Int, initiatedType: String, hits: Int, type: String, domainOwner: String, bundleid: String) {
        self.domain = domain
        self.firstTimeStamp = firstTimeStamp
        self.context = context
        self.timeStamp = timeStamp
        self.domainType = domainType
        self.initiatedType = initiatedType
        self.hits = hits
        self.type = type
        self.domainOwner = domainOwner
        self.bundleid = bundleid
    }
}

// MARK: NDNetworkAccess convenience initializers and mutators

public extension NDNetworkAccess {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NDNetworkAccess.self, from: data)
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
        domain: String? = nil,
        firstTimeStamp: String? = nil,
        context: String? = nil,
        timeStamp: String? = nil,
        domainType: Int? = nil,
        initiatedType: String? = nil,
        hits: Int? = nil,
        type: String? = nil,
        domainOwner: String? = nil,
        bundleid: String? = nil
    ) -> NDNetworkAccess {
        return NDNetworkAccess(
            domain: domain ?? self.domain,
            firstTimeStamp: firstTimeStamp ?? self.firstTimeStamp,
            context: context ?? self.context,
            timeStamp: timeStamp ?? self.timeStamp,
            domainType: domainType ?? self.domainType,
            initiatedType: initiatedType ?? self.initiatedType,
            hits: hits ?? self.hits,
            type: type ?? self.type,
            domainOwner: domainOwner ?? self.domainOwner,
            bundleid: bundleid ?? self.bundleid
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let ASAPIResult = try ASAPIResult(json)

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ASAPIResult

public struct ASAPIResult: Codable {
    public let resultCount: Int?
    public let results: [ASResult]?

    enum CodingKeys: String, CodingKey {
        case resultCount
        case results
    }

    public init(resultCount: Int?, results: [ASResult]?) {
        self.resultCount = resultCount
        self.results = results
    }
}

// MARK: ASAPIResult convenience initializers and mutators

public extension ASAPIResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ASAPIResult.self, from: data)
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
        resultCount: Int?? = nil,
        results: [ASResult]?? = nil
    ) -> ASAPIResult {
        return ASAPIResult(
            resultCount: resultCount ?? self.resultCount,
            results: results ?? self.results
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ASResult

public struct ASResult: Codable {
    public let screenshotUrls: [String]?
    public let ipadScreenshotUrls: [String]?
    public let appletvScreenshotUrls: [JSONAny]?
    public let artworkUrl60: String?
    public let artworkUrl512: String?
    public let artworkUrl100: String?
    public let artistViewurl: String?
    public let features: [String]?
    public let supportedDevices: [String]?
    public let advisories: [String]?
    public let isGameCenterEnabled: Bool?
    public let kind: String?
    public let averageUserRating: Double?
    public let minimumosVersion: String?
    public let trackCensoredName: String?
    public let languageCodesiso2a: [String]?
    public let fileSizeBytes: String?
    public let sellerurl: String?
    public let formattedPrice: String?
    public let contentAdvisoryRating: String?
    public let averageUserRatingForCurrentVersion: Double?
    public let userRatingCountForCurrentVersion: Int?
    public let trackViewurl: String?
    public let trackContentRating: String?
    public let bundleid: String?
    public let trackid: Int?
    public let trackName: String?
    public let releaseDate: Date?
    public let sellerName: String?
    public let primaryGenreName: String?
    public let genreids: [String]?
    public let isVppDeviceBasedLicensingEnabled: Bool?
    public let currentVersionReleaseDate: Date?
    public let releaseNotes: String?
    public let primaryGenreid: Int?
    public let currency: String?
    public let resultDescription: String?
    public let artistid: Int?
    public let artistName: String?
    public let genres: [String]?
    public let price: Int?
    public let version: String?
    public let wrapperType: String?
    public let userRatingCount: Int?

    enum CodingKeys: String, CodingKey {
        case screenshotUrls
        case ipadScreenshotUrls
        case appletvScreenshotUrls
        case artworkUrl60
        case artworkUrl512
        case artworkUrl100
        case artistViewurl = "artistViewUrl"
        case features
        case supportedDevices
        case advisories
        case isGameCenterEnabled
        case kind
        case averageUserRating
        case minimumosVersion = "minimumOsVersion"
        case trackCensoredName
        case languageCodesiso2a = "languageCodesISO2A"
        case fileSizeBytes
        case sellerurl = "sellerUrl"
        case formattedPrice
        case contentAdvisoryRating
        case averageUserRatingForCurrentVersion
        case userRatingCountForCurrentVersion
        case trackViewurl = "trackViewUrl"
        case trackContentRating
        case bundleid = "bundleId"
        case trackid = "trackId"
        case trackName
        case releaseDate
        case sellerName
        case primaryGenreName
        case genreids = "genreIds"
        case isVppDeviceBasedLicensingEnabled
        case currentVersionReleaseDate
        case releaseNotes
        case primaryGenreid = "primaryGenreId"
        case currency
        case resultDescription = "description"
        case artistid = "artistId"
        case artistName
        case genres
        case price
        case version
        case wrapperType
        case userRatingCount
    }

    public init(screenshotUrls: [String]?, ipadScreenshotUrls: [String]?, appletvScreenshotUrls: [JSONAny]?, artworkUrl60: String?, artworkUrl512: String?, artworkUrl100: String?, artistViewurl: String?, features: [String]?, supportedDevices: [String]?, advisories: [String]?, isGameCenterEnabled: Bool?, kind: String?, averageUserRating: Double?, minimumosVersion: String?, trackCensoredName: String?, languageCodesiso2a: [String]?, fileSizeBytes: String?, sellerurl: String?, formattedPrice: String?, contentAdvisoryRating: String?, averageUserRatingForCurrentVersion: Double?, userRatingCountForCurrentVersion: Int?, trackViewurl: String?, trackContentRating: String?, bundleid: String?, trackid: Int?, trackName: String?, releaseDate: Date?, sellerName: String?, primaryGenreName: String?, genreids: [String]?, isVppDeviceBasedLicensingEnabled: Bool?, currentVersionReleaseDate: Date?, releaseNotes: String?, primaryGenreid: Int?, currency: String?, resultDescription: String?, artistid: Int?, artistName: String?, genres: [String]?, price: Int?, version: String?, wrapperType: String?, userRatingCount: Int?) {
        self.screenshotUrls = screenshotUrls
        self.ipadScreenshotUrls = ipadScreenshotUrls
        self.appletvScreenshotUrls = appletvScreenshotUrls
        self.artworkUrl60 = artworkUrl60
        self.artworkUrl512 = artworkUrl512
        self.artworkUrl100 = artworkUrl100
        self.artistViewurl = artistViewurl
        self.features = features
        self.supportedDevices = supportedDevices
        self.advisories = advisories
        self.isGameCenterEnabled = isGameCenterEnabled
        self.kind = kind
        self.averageUserRating = averageUserRating
        self.minimumosVersion = minimumosVersion
        self.trackCensoredName = trackCensoredName
        self.languageCodesiso2a = languageCodesiso2a
        self.fileSizeBytes = fileSizeBytes
        self.sellerurl = sellerurl
        self.formattedPrice = formattedPrice
        self.contentAdvisoryRating = contentAdvisoryRating
        self.averageUserRatingForCurrentVersion = averageUserRatingForCurrentVersion
        self.userRatingCountForCurrentVersion = userRatingCountForCurrentVersion
        self.trackViewurl = trackViewurl
        self.trackContentRating = trackContentRating
        self.bundleid = bundleid
        self.trackid = trackid
        self.trackName = trackName
        self.releaseDate = releaseDate
        self.sellerName = sellerName
        self.primaryGenreName = primaryGenreName
        self.genreids = genreids
        self.isVppDeviceBasedLicensingEnabled = isVppDeviceBasedLicensingEnabled
        self.currentVersionReleaseDate = currentVersionReleaseDate
        self.releaseNotes = releaseNotes
        self.primaryGenreid = primaryGenreid
        self.currency = currency
        self.resultDescription = resultDescription
        self.artistid = artistid
        self.artistName = artistName
        self.genres = genres
        self.price = price
        self.version = version
        self.wrapperType = wrapperType
        self.userRatingCount = userRatingCount
    }
}

// MARK: ASResult convenience initializers and mutators

public extension ASResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ASResult.self, from: data)
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
        screenshotUrls: [String]?? = nil,
        ipadScreenshotUrls: [String]?? = nil,
        appletvScreenshotUrls: [JSONAny]?? = nil,
        artworkUrl60: String?? = nil,
        artworkUrl512: String?? = nil,
        artworkUrl100: String?? = nil,
        artistViewurl: String?? = nil,
        features: [String]?? = nil,
        supportedDevices: [String]?? = nil,
        advisories: [String]?? = nil,
        isGameCenterEnabled: Bool?? = nil,
        kind: String?? = nil,
        averageUserRating: Double?? = nil,
        minimumosVersion: String?? = nil,
        trackCensoredName: String?? = nil,
        languageCodesiso2a: [String]?? = nil,
        fileSizeBytes: String?? = nil,
        sellerurl: String?? = nil,
        formattedPrice: String?? = nil,
        contentAdvisoryRating: String?? = nil,
        averageUserRatingForCurrentVersion: Double?? = nil,
        userRatingCountForCurrentVersion: Int?? = nil,
        trackViewurl: String?? = nil,
        trackContentRating: String?? = nil,
        bundleid: String?? = nil,
        trackid: Int?? = nil,
        trackName: String?? = nil,
        releaseDate: Date?? = nil,
        sellerName: String?? = nil,
        primaryGenreName: String?? = nil,
        genreids: [String]?? = nil,
        isVppDeviceBasedLicensingEnabled: Bool?? = nil,
        currentVersionReleaseDate: Date?? = nil,
        releaseNotes: String?? = nil,
        primaryGenreid: Int?? = nil,
        currency: String?? = nil,
        resultDescription: String?? = nil,
        artistid: Int?? = nil,
        artistName: String?? = nil,
        genres: [String]?? = nil,
        price: Int?? = nil,
        version: String?? = nil,
        wrapperType: String?? = nil,
        userRatingCount: Int?? = nil
    ) -> ASResult {
        return ASResult(
            screenshotUrls: screenshotUrls ?? self.screenshotUrls,
            ipadScreenshotUrls: ipadScreenshotUrls ?? self.ipadScreenshotUrls,
            appletvScreenshotUrls: appletvScreenshotUrls ?? self.appletvScreenshotUrls,
            artworkUrl60: artworkUrl60 ?? self.artworkUrl60,
            artworkUrl512: artworkUrl512 ?? self.artworkUrl512,
            artworkUrl100: artworkUrl100 ?? self.artworkUrl100,
            artistViewurl: artistViewurl ?? self.artistViewurl,
            features: features ?? self.features,
            supportedDevices: supportedDevices ?? self.supportedDevices,
            advisories: advisories ?? self.advisories,
            isGameCenterEnabled: isGameCenterEnabled ?? self.isGameCenterEnabled,
            kind: kind ?? self.kind,
            averageUserRating: averageUserRating ?? self.averageUserRating,
            minimumosVersion: minimumosVersion ?? self.minimumosVersion,
            trackCensoredName: trackCensoredName ?? self.trackCensoredName,
            languageCodesiso2a: languageCodesiso2a ?? self.languageCodesiso2a,
            fileSizeBytes: fileSizeBytes ?? self.fileSizeBytes,
            sellerurl: sellerurl ?? self.sellerurl,
            formattedPrice: formattedPrice ?? self.formattedPrice,
            contentAdvisoryRating: contentAdvisoryRating ?? self.contentAdvisoryRating,
            averageUserRatingForCurrentVersion: averageUserRatingForCurrentVersion ?? self.averageUserRatingForCurrentVersion,
            userRatingCountForCurrentVersion: userRatingCountForCurrentVersion ?? self.userRatingCountForCurrentVersion,
            trackViewurl: trackViewurl ?? self.trackViewurl,
            trackContentRating: trackContentRating ?? self.trackContentRating,
            bundleid: bundleid ?? self.bundleid,
            trackid: trackid ?? self.trackid,
            trackName: trackName ?? self.trackName,
            releaseDate: releaseDate ?? self.releaseDate,
            sellerName: sellerName ?? self.sellerName,
            primaryGenreName: primaryGenreName ?? self.primaryGenreName,
            genreids: genreids ?? self.genreids,
            isVppDeviceBasedLicensingEnabled: isVppDeviceBasedLicensingEnabled ?? self.isVppDeviceBasedLicensingEnabled,
            currentVersionReleaseDate: currentVersionReleaseDate ?? self.currentVersionReleaseDate,
            releaseNotes: releaseNotes ?? self.releaseNotes,
            primaryGenreid: primaryGenreid ?? self.primaryGenreid,
            currency: currency ?? self.currency,
            resultDescription: resultDescription ?? self.resultDescription,
            artistid: artistid ?? self.artistid,
            artistName: artistName ?? self.artistName,
            genres: genres ?? self.genres,
            price: price ?? self.price,
            version: version ?? self.version,
            wrapperType: wrapperType ?? self.wrapperType,
            userRatingCount: userRatingCount ?? self.userRatingCount
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try jsonData(), encoding: encoding)
    }
}

// MARK: - Encode/decode helpers

public class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

public class JSONAny: Codable {
    public let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: value)
        }
    }
}
