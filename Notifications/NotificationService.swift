//
//  NotificationService.swift
//  Notifications
//
//  Created by Alex Rupérez on 05/09/2018.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import UserNotifications
import OneSignal

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var receivedRequest: UNNotificationRequest!

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        receivedRequest = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            OneSignal.didReceiveNotificationExtensionRequest(receivedRequest, with: bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignal.serviceExtensionTimeWillExpireRequest(receivedRequest, with: bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }

}
