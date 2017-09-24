//
//  DeepLinkingExtensions.swift
//  BiciMAD
//
//  Created by Alejandro Ruperez Hernando on 28/12/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

import Foundation

public extension NSURL {
    @objc public func deepLinkURL() -> URL? {
        guard let scheme = scheme, let host = host, let pathComponents = pathComponents, scheme.hasPrefix("http"), host.contains("madbikeapp") else {
            return nil
        }
        var deepLink = "madbike://"
        if pathComponents.count > 1 {
            deepLink = deepLink + pathComponents[1]
            if pathComponents.count > 2, let identifier = pathComponents[2].components(separatedBy: CharacterSet.decimalDigits.inverted).first {
                deepLink = deepLink + "/" + identifier
            }
        }
        return URL(string: deepLink)
    }

    public func deepLinkString() -> String? {
        return deepLinkURL()?.absoluteString
    }
}

public extension NSString {
    public func deepLinkURL() -> URL? {
        return NSURL(string: self as String)?.deepLinkURL()
    }

    public func deepLinkString() -> String? {
        return NSURL(string: self as String)?.deepLinkString()
    }
}
