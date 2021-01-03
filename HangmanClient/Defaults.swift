//
//  Defaults.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import Foundation

class Defaults {
    private init() {}

    private static let userDefaults = UserDefaults.standard

    static var playerID: Player.ID? {
        get {
            Self.userDefaults.object(forKey: "playerID") != nil ? UInt16(Self.userDefaults.integer(forKey: "playerID")) : nil
        }
        set {
            if let value = newValue {
                Self.userDefaults.set(Int(value), forKey: "playerID")
            } else {
                Self.userDefaults.removeObject(forKey: "playerID")
            }
        }
    }

    static var nick: String {
        get {
            Self.userDefaults.string(forKey: "nick") ?? ""
        }
        set {
            Self.userDefaults.set(newValue, forKey: "nick")
        }
    }
}
