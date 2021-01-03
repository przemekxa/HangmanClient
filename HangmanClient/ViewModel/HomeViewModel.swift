//
//  CreateRoomViewModel.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import Foundation

protocol HomeDelegate: AnyObject {
    func receivedSettings(possibleSettings: PossibleRoomSettings)
    func disconnected()
    func inRoom(with userID: Player.ID, status: RoomStatus)
}

class HomeViewModel: ObservableObject {

    // State
    @Published var nick: String = ""
    @Published var roomID: String = ""
    @Published var error: String?
    @Published var possibleSettings: PossibleRoomSettings?

    private let log = Log("🏠HomeVM")
    private var connection: Connection
    weak var delegate: HomeDelegate?

    private var userID: Player.ID?

    init(_ connection: Connection, possibleSettings: PossibleRoomSettings? = nil, error: String? = nil) {
        self.connection = connection
        self.connection.delegate = self
        self.error = error
        self.userID = UserDefaults.standard.object(forKey: "userID") != nil ? UInt16(UserDefaults.standard.integer(forKey: "userID")) : nil
        log.debug("Init with userID = %@", String(describing: userID))

        if let possibleSettings = possibleSettings {
            self.possibleSettings = possibleSettings
        } else {
            self.connection.send(.login(self.userID))
        }
    }

    func joinRoom(with id: String) {
        log.debug("Joining room with id %@", id)
        connection.send(.joinRoom(id))
    }

    func createRoom(with settings: RoomSettings) {
        log.debug("Creating room with settings: %@", String(describing: settings))
        connection.send(.createRoom(settings))
    }
}

extension HomeViewModel: ConnectionDelegate {
    
    func stateDidChange(to state: Connection.State) {
        if state != .ready {
            delegate?.disconnected()
        }
    }

    func received(_ message: InMessage) {
        log.debug("Received message: %@", String(describing: message))
        switch message {
        case .loggedIn(let id):
            UserDefaults.standard.set(id, forKey: "userID")
            userID = id
        case .error(let error):
            self.error = error.userDescription
        case .roomSettings(let settings):
            self.possibleSettings = settings
            delegate?.receivedSettings(possibleSettings: settings)
        case .roomStatus(let status):
            delegate?.inRoom(with: userID!, status: status)
        default:
            log.error("Message is not supported by this class")
        }
    }


}
