//
//  RoomViewModel.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import Foundation


protocol RoomDelegate: AnyObject {
    func disconnected()
    func left()
    func kicked()
}

class RoomViewModel: ObservableObject {

    // State
    @Published var status: RoomStatus
    @Published var isHost: Bool
    @Published var userID: Player.ID
    @Published var error: String?

    private let log = Log("👥RoomVM")
    private var connection: Connection
    weak var delegate: RoomDelegate?



    init(_ connection: Connection, userID: Player.ID, initialStatus status: RoomStatus) {
        self.connection = connection
        self.userID = userID
        self.status = status
        self.isHost = status.players.first(where: { $0.id == userID })?.isHost ?? false
        self.connection.delegate = self
        log.debug("Init")
    }

    func play() {
        log.debug("Play clicked")
        connection.send(.startGame())
    }

    func leave() {
        log.debug("Leave room")
        connection.send(.leaveRoom())
        delegate?.left()
    }

    func makeHost(_ player: Player) {
        log.debug("Make Player(id = '%d', nick = '%@') a host", player.id, player.nick)
        connection.send(.setNewHost(player))
    }

    func kick(_ player: Player) {
        log.debug("Kick Player(id = '%d', nick = '%@')", player.id, player.nick)
        connection.send(.kick(player))
    }

}

extension RoomViewModel: ConnectionDelegate {

    func stateDidChange(to state: Connection.State) {
        if state != .ready {
            delegate?.disconnected()
        }
    }

    func received(_ message: InMessage) {
        log.debug("Received message: %@", String(describing: message))
        switch message {
        case .error(let error):
            self.error = error.userDescription
        case .roomStatus(let status):
            self.status = status
        // TODO: Kicked message
        // case .kicked:
        //    delegate?.kicked()
        default:
            log.error("Message is not supported by this class")
        }
    }


}
