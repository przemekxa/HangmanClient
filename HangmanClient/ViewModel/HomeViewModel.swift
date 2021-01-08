//
//  CreateRoomViewModel.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import Foundation

protocol HomeDelegate: AnyObject {
    func loggedIn(with playerID: Player.ID)
    func receivedSettings(possibleSettings: PossibleRoomSettings)
    func disconnected()
    func inRoom(with playerID: Player.ID, status: RoomStatus)
    func inGame(with status: GameStatus)
}

class HomeViewModel: ObservableObject {

    // State
    @Published var nick: String = ""
    @Published var roomID: String = ""
    @Published var error: String?
    @Published var possibleSettings: PossibleRoomSettings?
    @Published var connectionInfo: String = ""

    private let log = Log("🏠HomeVM")
    private var connection: Connection
    weak var delegate: HomeDelegate?

    private var playerID: Player.ID?

    init(_ connection: Connection, possibleSettings: PossibleRoomSettings? = nil, error: String? = nil) {
        self.connection = connection
        self.connection.delegate = self
        self.error = error
        self.playerID = Defaults.playerID
        self.nick = Defaults.nick
        makeConnectionInfo(loggedIn: possibleSettings != nil)
        log.debug("Init with playerID = %@", String(describing: playerID))

        if let possibleSettings = possibleSettings {
            self.possibleSettings = possibleSettings
        } else {
            self.connection.send(.login(self.playerID))
        }
    }

    private func makeConnectionInfo(loggedIn: Bool) {
        let id = (loggedIn && Defaults.playerID != nil) ? "#" + String(Defaults.playerID!) + "\n" : ""
        let conn = (Defaults.lastHostname ?? "") + ":" + (Defaults.lastPort ?? "")
        connectionInfo = id + conn
    }

    func joinRoom(with id: String) {
        log.debug("Joining room with id %@", id)
        setNick()
        connection.send(.joinRoom(id))
    }

    func createRoom(with settings: RoomSettings) {
        log.debug("Creating room with settings: %@", String(describing: settings))
        setNick()
        connection.send(.createRoom(settings))
    }

    private func setNick() {
        if !nick.isEmpty {
            connection.send(.set(name: nick))
            Defaults.nick = nick
        }
    }
}

extension HomeViewModel: ConnectionDelegate {

    func stateDidChange(to state: Connection.State) {
        log.debug("State did change to: %@", String(describing: state))
        if state != .ready {
            delegate?.disconnected()
        }
    }

    func received(_ message: InMessage) {
        log.debug("Received message: %@", String(describing: message))
        switch message {
        case .loggedIn(let id):
            playerID = id
            Defaults.playerID = id
            makeConnectionInfo(loggedIn: true)
            delegate?.loggedIn(with: id)
        case .error(let error):
            self.error = error.userDescription
        case .roomSettings(let settings):
            self.possibleSettings = settings
            delegate?.receivedSettings(possibleSettings: settings)
        case .roomStatus(let status):
            delegate?.inRoom(with: playerID!, status: status)
        case .gameStatus(let status):
            delegate?.inGame(with: status)
        default:
            log.error("Message is not supported by this class")
        }
    }

}
