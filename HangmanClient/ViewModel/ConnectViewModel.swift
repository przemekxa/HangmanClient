//
//  ConnectViewModel.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import Foundation
import Combine
import Network

protocol ConnectDelegate: AnyObject {
    func connected(connection: Connection)
}

class ConnectViewModel: ObservableObject, ConnectionDelegate {

    // State of the window
    @Published var host: String
    @Published var port: String
    @Published var canConnect: Bool = true
    @Published var isConnecting: Bool = false
    @Published var connectionError: String?

    private let log = Log("🔗ConnectVM")
    private var cancellabes = Set<AnyCancellable>()
    private var connection: Connection?
    weak var delegate: ConnectDelegate?

    init(_ error: String? = nil) {

        if let error = error {
            log.debug("Init with error: %@", error)
        } else {
            log.debug("Init")
        }

        self.host = Defaults.lastHostname ?? "127.0.0.1"
        self.port = Defaults.lastPort ?? "1234"
        self.connectionError = error

        // Check if the port is correct
        $port
            .map { NWEndpoint.Port($0) != nil }
            .sink { [weak self] correct in
                self?.canConnect = correct
            }
            .store(in: &cancellabes)
    }

    func connect() {
        log.debug("Connect clicked")
        connectionError = nil
        if canConnect, let port = NWEndpoint.Port(port) {
            connection = Connection(hostname: NWEndpoint.Host(host), port: port, delegate: self)
            connection?.start()
            isConnecting = true
            Defaults.lastHostname = self.host
            Defaults.lastPort = self.port
        }
    }

    func stateDidChange(to state: Connection.State) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if state == .ready {
                self.log.info("Connected")
                self.isConnecting = false
                self.connectionError = nil
                self.delegate?.connected(connection: self.connection!)
            } else {
                self.log.info("Error connecting")
                self.isConnecting = false
                self.connectionError = "Błąd połączenia"
            }
        }
    }

    func received(_ message: InMessage) {
        log.info("Received a message after connection: %@", String(describing: message))
    }
}
