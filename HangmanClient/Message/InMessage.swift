//
//  InMessage.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

enum InMessage: Equatable {
    case loggedIn(Player.ID)
    case error(MessageError)
    case roomSettings(PossibleRoomSettings)
    case roomStatus(RoomStatus)
    case gameStatus(GameStatus)
    case scoreboard([PlayerScoreboard])

    /// Initialize incoming message from raw message
    init?(_ raw: Message) {
        var parsed: Self?

        switch raw.type {
        case .loggedIn:
            parsed = Self.loggedIn(raw.data)
        case .error:
            parsed = Self.error(raw.data)
        case .roomSettings:
            parsed = Self.roomSettings(raw.data)
        case .roomStatus:
            parsed = Self.roomStatus(raw.data)
        case .gameStatus:
            parsed = Self.gameStatus(raw.data)
        case .scoreBoard:
            parsed = Self.scoreboard(raw.data)
        default:
            break
        }

        if let message = parsed {
            self = message
        } else {
            return nil
        }
    }
}

// MARK: - Parsing logic

extension InMessage {

    /// Parse 'loggedIn' message
    private static func loggedIn(_ data: Data?) -> Self? {
        guard let data = data, data.count == 2 else { return nil }
        return .loggedIn(UInt16(bigEndian: data))
    }

    /// Parse 'error' message
    private static func error(_ data: Data?) -> Self? {
        guard let data = data,
              data.count == 1,
              let err = MessageError(rawValue: data[0]) else { return nil }
        return .error(err)
    }

    /// Parse 'roomSettings' message
    private static func roomSettings(_ data: Data?) -> Self? {
        guard let data = data, data.count >= 13 else { return nil }

        let languageCount = data[0]
        var languageCodes = [String]()

        var i = 1
        while i < (2 * languageCount) + 1 {
            languageCodes.append(String(bytes: [data[i], data[i+1]], encoding: .ascii)!)
            i += 2
        }
        let languages = languageCodes.map { Language($0) }
        let wordLength = data[i]...data[i+1]

        let minGameTime = UInt16(bigEndian: Data([data[i+2], data[i+3]]))
        let maxGameTime = UInt16(bigEndian: Data([data[i+4], data[i+5]]))
        let gameTime = minGameTime...maxGameTime

        let healthPoints = data[i+6]...data[i+7]

        assert(data[i+8]<=data[i+9])
        let playerCount = data[i+8]...data[i+9]
        assert(playerCount.lowerBound > 0)
        assert(playerCount.upperBound > 0)

        let settings = PossibleRoomSettings(languages: languages,
                                            wordLength: wordLength,
                                            gameTime: gameTime,
                                            healthPoints: healthPoints,
                                            playerCount: playerCount)

        return .roomSettings(settings)
    }

    /// Parse 'roomStatus' message
    private static func roomStatus(_ data: Data?) -> Self? {
        guard let data = data, data.count >= 15 else { return nil }

        let language = Language(String(bytes: data[0...1], encoding: .ascii)!)
        let wordLength = data[2]
        let gameTime = UInt16(bigEndian: Data(data[3...4]))
        let healthPoints = data[5]
        let roomID = String(data: Data(data[6...11]), encoding: .ascii)!
        let playerCount = data[12]

        var players = [Player]()
        var i = 13
        while players.count < playerCount {
            let id = UInt16(bigEndian: Data(data[i...i+1]))
            print("ID = \(id)")
            let nickLength = Int(data[i+2])
            i += 3
            let nick = String(data: Data(data[i..<i+nickLength]), encoding: .utf8) ?? "Unknown"
            i += nickLength
            players.append(Player(id: id, nick: nick))
        }
        let hostID = UInt16(bigEndian: Data(data[i...i+1]))
        if let index = players.firstIndex(where: { $0.id == hostID }) {
            players[index].isHost = true
        }

        let status = RoomStatus(language: language,
                                wordLength: wordLength,
                                gameTime: gameTime,
                                healthPoints: healthPoints,
                                id: roomID,
                                players: players)

        return .roomStatus(status)
    }

    /// Parse 'gameStatus' message
    private static func gameStatus(_ data: Data?) -> Self? {
        guard let data = data, data.count >= 4 else { return nil }

        let remainingTime = Double(UInt16(bigEndian: Data(data[0...1])))
        let playerCount = data[2]

        var players = [PlayerInGame]()
        var i = 3
        while players.count < playerCount {
            let id = UInt16(bigEndian: Data(data[i...i+1]))
            let nickLength = Int(data[i+2])
            i += 3
            let nick = String(data: Data(data[i..<i+nickLength]), encoding: .utf8) ?? "Unknown"
            i += nickLength
            let points = UInt16(bigEndian: Data(data[i...i+1]))
            let remainingHealth = data[i+2]
            let guessed = data[i+3] != 0
            i += 4
            players.append(PlayerInGame(id: id,
                                        nick: nick,
                                        points: points,
                                        remainingHealth:
                                            remainingHealth,
                                        guessed: guessed))
        }
        let wordLength = Int(data[i])
        let word = Array(String(data: Data(data[i+1..<i+1+wordLength]), encoding: .utf8)!)
            .map { $0 == Character(Unicode.Scalar(0)) ? nil : $0 }

        return .gameStatus(GameStatus(remainingTime: remainingTime, players: players, word: word))
    }

    /// Parse 'gameStatus' message
    private static func scoreboard(_ data: Data?) -> Self? {
        guard let data = data, data.count >= 1 else { return nil }

        let playerCount = data[0]
        var players = [PlayerScoreboard]()
        var i = 1
        while players.count < playerCount {
            let id = UInt16(bigEndian: Data(data[i...i+1]))
            let nickLength = Int(data[i+2])
            i += 3
            let nick = String(data: Data(data[i..<i+nickLength]), encoding: .utf8) ?? "Unknown"
            i += nickLength
            let points = UInt16(bigEndian: Data(data[i...i+1]))
            i += 2
            players.append(PlayerScoreboard(id: id, nick: nick, points: points))
        }

        return .scoreboard(players)

    }

}
