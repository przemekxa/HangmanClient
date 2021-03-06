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
    case kicked
    case gameStatus(GameStatus)
    case scoreboard(Scoreboard)

    /// Initialize incoming message from raw message
    init?(_ raw: Message) {
        var parsed: Self?

        switch raw.type {
        case .loggedIn:
            parsed = .loggedIn(raw.data)
        case .error:
            parsed = .error(raw.data)
        case .roomSettings:
            parsed = .roomSettings(raw.data)
        case .roomStatus:
            parsed = .roomStatus(raw.data)
        case .kicked:
            parsed = .kicked
        case .gameStatus:
            parsed = .gameStatus(raw.data)
        case .scoreBoard:
            parsed = .scoreboard(raw.data)
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
        let maxPlayers = data[12]
        let playerCount = data[13]

        var players = [Player]()
        var i = 14
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
                                maxPlayers: maxPlayers,
                                players: players)

        return .roomStatus(status)
    }

    /// Parse 'gameStatus' message
    private static func gameStatus(_ data: Data?) -> Self? {
        guard let data = data, data.count >= 4 else { return nil }

        let endTime = Date(timeIntervalSince1970: Double(UInt64(bigEndian: Data(data[0...7]))))
        let playerCount = data[8]

        var players = [PlayerInGame]()
        var i = 9
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
        let wordLength = Int(data[i]) * 4
        let word = Array(String(data: Data(data[i+1..<i+1+wordLength]), encoding: .utf32BigEndian)!)
            .map { $0 == Character(Unicode.Scalar(0)) ? nil : $0 }

        return .gameStatus(GameStatus(endTime: endTime, players: players, word: word))
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
            let guessed = data[i+2] != 0
            i += 3
            players.append(PlayerScoreboard(id: id, nick: nick, points: points, guessed: guessed))
        }
        let wordLength = Int(data[i]) * 4
        let word = String(data: Data(data[i+1..<i+1+wordLength]), encoding: .utf32BigEndian)!

        return .scoreboard(Scoreboard(players: players, word: word))

    }

}
