//
//  RNCryptorManager.swift
//  BiciMAD
//
//  Created by Alejandro Ruperez Hernando on 19/12/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

import RNCryptor

class RNCryptorManager: NSObject {

    @objc static func decryptData(_ data: Data, password: String) -> Data? {
        do {
            return try RNCryptor.decrypt(data: data, withPassword: password)
        } catch {
            return nil
        }
    }

    @objc static func encryptData(_ data: Data, password: String) -> Data {
        return RNCryptor.encrypt(data: data, withPassword: password)
    }

}
