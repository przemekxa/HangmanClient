//
//  OutMessage.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

extension Message {

    /// Create 'Login' requets message
    static func login(_ id: Player.ID? = nil) -> Self {
        return Message(type: .login, data: id?.bigEndianData)
    }

    /// Create 'setName' message
    /// - Parameter name: Player nickname
    static func set(name: String) -> Self {
        return Message(type: .setName, data: name.data(using: .utf8)!)
    }

    /// Create 'joinRoom' message
    /// - Parameter roomID: Room ID - 6 number characters ('0' - '9')
    static func joinRoom(_ roomID: String) -> Self {
        return Message(type: .joinRoom, data: roomID.data(using: .utf8)!)
    }

    /// Create 'createRoom' message
    /// - Parameter settings: Room settings
    static func createRoom(_ settings: RoomSettings) -> Self {
        var data = Data()
        data += settings.language.id.data(using: .utf8)!
        data.append(settings.wordLength)
        data += settings.gameTime.bigEndianData
        data.append(settings.healthPoints)
        data.append(settings.maxPlayers)
        assert(data.count == 7, "Message 'createRoom' should be 7 bytes long")
        return Message(type: .createRoom, data: data)
    }

    /// Create 'setNewHost' message
    /// - Parameter player: Player to become the new host
    static func setNewHost(_ player: Player) -> Self {
        return Message(type: .setNewHost, data: player.id.bigEndianData)
    }

    /// Create 'kickPlayer' message
    /// - Parameter player: Player to be kicked
    static func kick(_ player: Player) -> Self {
        return Message(type: .kickPlayer, data: player.id.bigEndianData)
    }

    /// Create 'leaveRoom' message
    static func leaveRoom() -> Self {
        return Message(type: .leaveRoom)
    }

    /// Create 'startGame' message
    static func startGame() -> Self {
        return Message(type: .startGame)
    }

    /// Create 'guessWord' message
    /// - Parameter word: Guessed word
    static func guess(word: String) -> Self {
        return Message(type: .guessWord, data: word.data(using: .utf8)!)
    }

    /// Create 'guessLetter' message
    /// - Parameter letter: Guessed letter
    static func guess(letter: Character) -> Self {
        let data = Data(letter.utf8)
        assert(data.count >= 1 && data.count <= 4, "UTF-8 Character should be 1-4 bytes long")
        return Message(type: .setName, data: data)
    }

}
