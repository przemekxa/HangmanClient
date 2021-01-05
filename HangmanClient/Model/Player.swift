//
//  Player.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 29/12/2020.
//

import Foundation

struct Player: Equatable, Hashable, Identifiable {
    typealias ID = UInt16

    let id: ID
    var nick: String
    var isHost: Bool = false
}

struct PlayerInGame: Equatable, Identifiable {
    let id: Player.ID
    let nick: String
    let points: UInt16
    let remainingHealth: UInt8
    let guessed: Bool
}

struct PlayerScoreboard: Equatable, Hashable, Identifiable {
    let id: Player.ID
    let nick: String
    let points: UInt16
}
