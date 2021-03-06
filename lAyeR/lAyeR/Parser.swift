//
//  Parser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

/*
 * This class parses the search query and decodes the response into relative objects.
 */
class Parser {
    
    /// Returns the singleton instance of parser
    static let instance = Parser()
    
    /// Parses poi search request
    /// - Parameters:
    ///     - radius: Int: detection radius
    ///     - type: String: desired poi category
    ///     - location: GeoPoint: center of search range
    /// - Returns:
    ///     - String: the string url of the query
    static func parsePOISearchRequest(_ radius: Int, _ type: String, _ location: GeoPoint) -> String {
        let searchBase = AppConfig.mapQueryBaseURL
        let locationToken = "location=\(location.latitude),\(location.longitude)"
        let radiusToken = "&radius=\(radius)"
        let typeToken = "&type=\(type)"
        let keyToken = "&key=\(AppConfig.apiKey)"
        return "\(searchBase)\(locationToken)\(radiusToken)\(typeToken)\(keyToken)"
    }
    
    /// Parses poi details search request.
    /// - Parameters:
    ///     - placeID: String: place id of the point
    /// - Returns:
    ///     - String: the string url of the query
    static func parsePOIDetailSearchRequest(_ placeID: String) -> String {
        let searchbase = AppConfig.poiQueryBaseURL
        let placeToken = "placeid=\(placeID)"
        let keyToken = "&key=\(AppConfig.apiKey)"
        return "\(searchbase)\(placeToken)\(keyToken)"
    }
    
    /// Parses query response to an poi array
    /// - Parameters:
    ///     - value: Any?: query response
    /// - Returns:
    ///     - [POI]: an array of POI object
    static func parsePOIs(_ value: Any?) -> [POI] {
        guard let json = value as? [String: Any],
              let results = json[ModelConstants.resultsKey] as? [[String: Any]] else {
            return []
        }
        var pois: [POI] = []
        for result in results {
            guard let poi = parsePOI(result) else {
                continue
            }
            pois.append(poi)
        }
        return pois
    }
    
    /// Parses json dictionary to a poi object with basic information if valid, nil otherwise
    /// - Parameters:
    ///     - value: Any?: query response
    /// - Returns:
    ///     - POI?: a POI object if response is valid, nil otherwise
    static func parsePOI(_ jsonPOI: [String: Any]) -> POI? {
        guard let geometry = jsonPOI[ModelConstants.geometryKey] as? [String: Any],
              let location = geometry[ModelConstants.locationKey] as? [String: Any],
              let latitude = location[ModelConstants.poiLatKey] as? Double,
              let longitude = location[ModelConstants.poiLonKey] as? Double else {
            return nil
        }
        let poi = POI(latitude, longitude)
        if let placeID = jsonPOI[ModelConstants.placeIDKey] as? String {
            poi.setPlaceID(placeID)
        }
        if let name = jsonPOI[ModelConstants.nameKey] as? String {
            poi.setName(name)
        }
        if let vicinity = jsonPOI[ModelConstants.vicinityKey] as? String {
            poi.setVicinity(vicinity)
        }
        if let types = jsonPOI[ModelConstants.typesKey] as? [String] {
            poi.setTypes(types)
        }
        return poi
    }
    
    /// Parses query response to a poi object with details if valid, nil otherwise
    /// - Parameters:
    ///     - value: Any?: query response
    /// - Returns:
    ///     - POI?: a POI object if response is valid, nil otherwise
    static func parseDetailedPOI(_ value: Any?) -> POI? {
        guard let json = value as? [String: Any],
              let jsonPOI = json[ModelConstants.resultKey] as? [String: Any],
              let poi = parsePOI(jsonPOI) else {
            return nil
        }
        if let address = jsonPOI[ModelConstants.addressKey] as? String {
            poi.setVicinity(address)
        }
        if let priceLevel = jsonPOI[ModelConstants.priceLevelKey] as? Double {
            poi.setPriceLevel(priceLevel)
        }
        if let openHours = jsonPOI[ModelConstants.openStatusKey] as? [String: Any],
           let openNow = openHours[ModelConstants.openNowKey] as? Bool {
            poi.setOpenNow(openNow)
        }
        if let rating = jsonPOI[ModelConstants.ratingKey] as? Double {
            poi.setRating(rating)
        }
        if let website = jsonPOI[ModelConstants.websiteKey] as? String {
            poi.setWebsite(website)
        }
        if let contact = jsonPOI[ModelConstants.contactKey] as? String {
            poi.setContact(contact)
        }
        return poi
    }
    
    /// Parses query response to a route object if valid, nil otherwise
    /// - Parameters:
    ///     - value: Any?: query response
    /// - Returns:
    ///     - Route?: an route object if response is valid, nil otherwise
    static func parseRoute(_ value: Any?) -> Route? {
        guard let jsonRoute = value as? [String: Any],
            let points = jsonRoute[ModelConstants.checkPointsKey] as? [[String: Any]],
            let name = jsonRoute[ModelConstants.nameKey] as? String,
            let checkPoints = points.map ({ CheckPoint(JSON: $0) }) as? [CheckPoint],
            let image = jsonRoute[ModelConstants.imagePathKey] as? String else {
                return nil
        }
        let route = Route(name, checkPoints)
        route.setImage(path: image)
        return route
    }
    
    /// Parses response to track points if valid, return empty array otherwise
    /// - Parameters:
    ///     - value: Any?: query response
    /// - Returns:
    ///     - [TrackPoint]: array of parsed track points
    static func parseTrackPoints(_ value: Any?) -> [TrackPoint] {
        var trackPoints: [TrackPoint] = []
        guard let latdict = value as? [String: Any],
            let lat = latdict[ModelConstants.latitudeKey] as? Double else {
                return trackPoints
        }
        var londicts: [[String: Any]] = []
        for latdictvalue in latdict.values {
            guard let latdictvalue = latdictvalue as? [String: Any] else {
                continue
            }
            londicts.append(latdictvalue)
        }
        for londict in londicts {
            guard let lon = londict[ModelConstants.longitudeKey] as? Double else {
                continue
            }
            let trackPoint = TrackPoint(lat, lon)
            trackPoint.up = londict[ModelConstants.upKey] as? Bool ?? false
            trackPoint.down = londict[ModelConstants.downKey] as? Bool ?? false
            trackPoint.left = londict[ModelConstants.leftKey] as? Bool ?? false
            trackPoint.right = londict[ModelConstants.rightKey] as? Bool ?? false
            trackPoints.append(trackPoint)
        }
        return trackPoints
    }
    
}
