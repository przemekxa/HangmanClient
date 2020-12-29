//
//  ConsoleClientTest.swift
//  ConsoleClientTest
//
//  Created by Przemek Ambroży on 29/12/2020.
//

import XCTest

extension String {
    var ascii: [UInt8] {
        Array(self.data(using: .ascii)!)
    }
    var utf8: [UInt8] {
        Array(self.data(using: .utf8)!)
    }
}

class ConsoleClientTest: XCTestCase {

    func testLogin() {
        var msg = Message.login(0x1234)
        XCTAssertEqual(msg.type, .login)
        XCTAssertEqual(msg.data, Data([0x12, 0x34]))
        msg = Message.login()
        XCTAssertEqual(msg.type, .login)
        XCTAssertNil(msg.data)
    }

    func testLoggedIn() {
        let data: [UInt8] = [0x12, 0x34]
        let msg = InMessage(Message(type: .loggedIn, data: Data(data)))
        XCTAssertNotNil(msg)
        XCTAssertEqual(msg!, .loggedIn(0x1234))
    }

    func testSetName() {
        let msg = Message.set(name: "Hasło 💬")
        XCTAssertEqual(msg.type, .setName)
        XCTAssertEqual(msg.data!, Data([0x48, 0x61, 0x73, 0xc5, 0x82, 0x6f, 0x20, 0xf0, 0x9f, 0x92, 0xac]))
    }

    func testJoinRoom() {
        let msg = Message.joinRoom("123456")
        XCTAssertEqual(msg.type, .joinRoom)
        XCTAssertEqual(msg.data!, Data([0x31, 0x32, 0x33, 0x34, 0x35, 0x36]))
    }

    func testError() {

        let msg = InMessage(Message(type: .error, data: Data([MessageError.roomFull.rawValue])))
        XCTAssertNotNil(msg)

        if case .error(let err) = msg! {
            XCTAssertEqual(err, MessageError.roomFull)
        } else {
            XCTFail("Wrong decoded message type")
        }
    }

    func testCreateRoom() {
        let msg = Message.createRoom(RoomSettings(language: Language("pl"),
                                                  wordLength: 0x12,
                                                  gameTime: 0xabcd,
                                                  healthPoints: 0x34,
                                                  maxPlayers: 0x01))
        let data: [UInt8] = "pl".ascii + [0x12, 0xab, 0xcd, 0x34, 0x01]

        XCTAssertEqual(msg.type, .createRoom)
        XCTAssertEqual(msg.data, Data(data))
    }

    func testRoomSettings() {
        let data: [UInt8] = [2] + "plus".ascii + [
            3, 5, // word length
            0, 30, 0x01, 0xaa, // game time
            1, 3, // health points
            2, 5 // players
        ]
        let msg = InMessage(Message(type: .roomSettings, data: Data(data)))
        XCTAssertNotNil(msg)

        if case .roomSettings(let settings) = msg! {
            XCTAssertEqual(settings.languages, [Language("pl"), Language("us")])
            XCTAssertEqual(settings.wordLength, 3...5)
            XCTAssertEqual(settings.gameTime, 30...0x01aa)
            XCTAssertEqual(settings.healthPoints, 1...3)
            XCTAssertEqual(settings.playerCount, 2...5)
        } else {
            XCTFail("Wrong decoded message type")
        }

    }

    func testRoomStatus() {
        var data: [UInt8] = "pl".ascii
         data += [
            25, // word length
            0x01, 0xaa, // game time
            250 // health points
        ]
        data += "123456".ascii // room id
        data += [2] // number of players
        data += [0x11, 0x22, 3] + "one".utf8 // First player
        data += [0x33, 0x44, 4] + "jąn".utf8 // Second player
        data += [0x11, 0x22]

        let msg = InMessage(Message(type: .roomStatus, data: Data(data)))
        XCTAssertNotNil(msg)

        if case .roomStatus(let status) = msg! {
            XCTAssertEqual(status.language, Language("pl"))
            XCTAssertEqual(status.wordLength, 25)
            XCTAssertEqual(status.gameTime, 0x01aa)
            XCTAssertEqual(status.healthPoints, 250)
            XCTAssertEqual(status.id, "123456")
            XCTAssertEqual(status.players.count, 2)
            XCTAssertEqual(status.players[0], Player(id: 0x1122, nick: "one", isHost: true))
            XCTAssertEqual(status.players[1], Player(id: 0x3344, nick: "jąn", isHost: false))
        } else {
            XCTFail("Wrong decoded message type")
        }

    }

    func testSetNewHost() {
        let msg = Message.setNewHost(Player(id: 0x1234, nick: "Some nick", isHost: false))
        XCTAssertEqual(msg.type, .setNewHost)
        XCTAssertEqual(msg.data!, Data([0x12, 0x34]))
    }

    func testKickPlayer() {
        let msg = Message.kick(Player(id: 0x1234, nick: "Some nick", isHost: false))
        XCTAssertEqual(msg.type, .kickPlayer)
        XCTAssertEqual(msg.data!, Data([0x12, 0x34]))
    }

    func testLeaveRoom() {
        let msg = Message.leaveRoom()
        XCTAssertEqual(msg.type, .leaveRoom)
        XCTAssertNil(msg.data)
    }

    func testStartGame() {
        let msg = Message.startGame()
        XCTAssertEqual(msg.type, .startGame)
        XCTAssertNil(msg.data)
    }

    func testGameStatus() {
        var data: [UInt8] = [
            0x01, 0x23, // time left
            3 // number of players
        ]
        data += [0x11, 0x22, 3] + "one".utf8 + [0x00, 0x10, 2, 0]
        data += [0x33, 0x44, 4] + "test".utf8 + [0x01, 0x20, 1, 0]
        data += [0x55, 0x66, 5] + "wąż".utf8 + [0x30, 0x20, 3, 1]
        data += [5] // word length
        data += "wę".utf8 + [0] + "e".utf8 // word: 'w' 'ę' _ 'e'

        let msg = InMessage(Message(type: .gameStatus, data: Data(data)))
        XCTAssertNotNil(msg)

        if case .gameStatus(let status) = msg! {
            XCTAssertEqual(status.remainingTime, Double(0x0123))
            XCTAssertEqual(status.players.count, 3)
            XCTAssertEqual(status.players[0], PlayerInGame(id: 0x1122,
                                                           nick: "one",
                                                           points: 0x0010,
                                                           remainingHealth: 2,
                                                           guessed: false))
            XCTAssertEqual(status.players[1], PlayerInGame(id: 0x3344,
                                                           nick: "test",
                                                           points: 0x0120,
                                                           remainingHealth: 1,
                                                           guessed: false))
            XCTAssertEqual(status.players[2], PlayerInGame(id: 0x5566,
                                                           nick: "wąż",
                                                           points: 0x3020,
                                                           remainingHealth: 3,
                                                           guessed: true))
        } else {
            XCTFail("Wrong decoded message type")
        }
    }

    func testGuessWord() {
        let msg = Message.guess(word: "Słowo")
        XCTAssertEqual(msg.type, .guessWord)
        XCTAssertEqual(msg.data, Data("Słowo".utf8))
    }

    func testGuessLetter() {
        var msg = Message.guess(letter: "a")
        XCTAssertEqual(msg.type, .guessLetter)
        XCTAssertEqual(msg.data, Data([0x61]))

        msg = Message.guess(letter: "ą")
        XCTAssertEqual(msg.type, .guessLetter)
        XCTAssertEqual(msg.data, Data([0xc4, 0x85]))

        msg = Message.guess(letter: "€")
        XCTAssertEqual(msg.type, .guessLetter)
        XCTAssertEqual(msg.data, Data([0xe2, 0x82, 0xac]))

        msg = Message.guess(letter: "𐍈")
        XCTAssertEqual(msg.type, .guessLetter)
        XCTAssertEqual(msg.data, Data([0xf0, 0x90, 0x8d, 0x88]))
    }

    func testScoreboard() {
        var data: [UInt8] = [3] // number of playets
        data += [0x12, 0x34, 3] + "123".utf8 + [0xab, 0xcd]
        data += [0x56, 0x78, 15] + "Dłuższa nazwa".utf8 + [0x00, 0x00]
        data += [0x9a, 0xbc, 13] + "🎮Emoji🎮".utf8 + [0x98, 0x76]

        let msg = InMessage(Message(type: .scoreBoard, data: Data(data)))
        XCTAssertNotNil(msg)

        if case .scoreboard(let players) = msg! {
            XCTAssertEqual(players.count, 3)
            XCTAssertEqual(players.count, 3)
            XCTAssertEqual(players[0], PlayerScoreboard(id: 0x1234, nick: "123", points: 0xabcd))
            XCTAssertEqual(players[1], PlayerScoreboard(id: 0x5678, nick: "Dłuższa nazwa", points: 0x0000))
            XCTAssertEqual(players[2], PlayerScoreboard(id: 0x9abc, nick: "🎮Emoji🎮", points: 0x9876))
        } else {
            XCTFail("Wrong decoded message type")
        }
    }

}
