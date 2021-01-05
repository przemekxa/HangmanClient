//
//  RoomSettings.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 29/12/2020.
//

import Foundation

struct Language: Equatable, Hashable, Identifiable {
    let id: String
    let name: String

    init(_ id: String) {
        let id = id.data(using: .utf8)!.count == 2 ? id : "pl"
        self.id = id
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: id) {
            self.name = Self.flag(from: id) + name
        } else {
            self.name = Self.flag(from: id) + id
        }
    }

    /// Create a flag from country code
    private static func flag(from country: String) -> String {
        let base: UInt32 = 127397
        var str = ""
        for scalar in country.uppercased().unicodeScalars {
            str.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
        }
        return str
    }
}

// MARK: - Room settings

struct RoomSettings: Equatable {
    var language: Language
    var wordLength: UInt8
    var gameTime: UInt16
    var healthPoints: UInt8
    var maxPlayers: UInt8
}

struct PossibleRoomSettings: Equatable {
    var languages: [Language]
    var wordLength: ClosedRange<UInt8>
    var gameTime: ClosedRange<UInt16>
    var healthPoints: ClosedRange<UInt8>
    var playerCount: ClosedRange<UInt8>
}

// MARK: - Room status

struct RoomStatus: Equatable {
    let language: Language
    let wordLength: UInt8
    let gameTime: UInt16
    let healthPoints: UInt8
    let id: String
    let maxPlayers: UInt8
    let players: [Player]
}

// MARK: - Game status

struct GameStatus: Equatable {
    let endTime: Date
    let players: [PlayerInGame]
    let word: [Character?]
}
