//
//  BMFavoritesManager+Analytics.swift
//  BiciMAD
//
//  Created by alexruperez on 6/11/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

import Foundation

extension BMFavoritesManager {
    @objc func log(_ favorites: [AnyObject]) {
        guard let stations = favorites as? [BMStation] else {
            return
        }
        var customAttributes: [String : String] = [:]
        for station in stations {
            if let stationId = station.stationId {
                customAttributes["Station\(stationId)"] = station.favorite ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo
            }
        }
        BMAnalyticsManager.logFavorites(customAttributes)
    }
}
