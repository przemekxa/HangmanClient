//
//  Message.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

/// Type of the message
enum MessageType: UInt8, Equatable {
    case unknown = 0x00

    // K > S
    case login = 0x11
    case setName = 0x12
    case joinRoom = 0x21
    case createRoom = 0x22
    case setNewHost = 0x23
    case kickPlayer = 0x24
    case leaveRoom = 0x25
    case startGame = 0x26
    case guessWord = 0x31
    case guessLetter = 0x32

    // S > K
    case loggedIn = 0x91
    case error = 0x81
    case roomSettings = 0xa1
    case roomStatus = 0xa2
    case kicked = 0xa3
    case gameStatus = 0xb1
    case scoreBoard = 0xb2
}

enum MessageError: UInt8, Error, Equatable {
    case unknown = 0
    case roomFull = 1
    case roomNotFound = 2
    case newHostNotFound = 3
    case kickPlayerNotFound = 4

    var userDescription: String {
        switch self {
        case .unknown:
            return "Nieznany błąd"
        case .roomFull:
            return "Pokój pełem"
        case .roomNotFound:
            return "Nie znaleziono pokoju"
        case .newHostNotFound:
            return "Nie znaleziono gracza mającego być hostem"
        case .kickPlayerNotFound:
            return "Nie znaleziono gracza mającego być wyrzuconym"
        }
    }
}

struct Message {
    let type: MessageType
    let data: Data?

    init(type: MessageType, data: Data? = nil) {
        self.type = type
        self.data = data
    }
}
