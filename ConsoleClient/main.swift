//
//  main.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation
import Network

class Controller: ConnectionDelegate {

    // Connection
    private var hostname: NWEndpoint.Host
    private var port: NWEndpoint.Port
    private var connection: Connection

    private let log = Log("🕹️Controller")

    // State
    private(set) var id: UInt16?
    private(set) var connected = false
    private(set) var loggedIn = false

    init(id: Player.ID? = nil) {
        self.id = id
        hostname = "127.0.0.1"
        port = 1234
        connection = Connection(hostname: hostname, port: port)
        connection.delegate = self
        connection.start()
    }

    // State of the connection changed
    func stateDidChange(to state: Connection.State) {
        switch state {

        // Connection ready, login
        case .ready:
            connected = true
            login()

        // Connection waiting
        case .waiting(let description):
            connected = false
            log.error("Connection waiting error: %@", description)

        // Connection error
        case .error(let description):
            connected = false
            log.error("Connection error: %@", description)

        // Connection ended
        case .ended:
            connected = false
            log.info("Connection ended")

        }
    }

    // Called when new message is received
    func received(_ message: InMessage) {
        log("Received message: %@", String(describing: message))

        switch message {

        // Logged in to the server
        case .loggedIn(let id):
            loggedIn = true
            self.id = id

        default:
            break
        }
    }

    /// Login to the server
    private func login() {
        log.debug("Sending login message with player ID:", String(describing: id))
        connection.send(.login(id))
    }

}

let controller = Controller()
RunLoop.main.run()
