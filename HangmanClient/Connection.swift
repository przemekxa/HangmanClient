//
//  Connection.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation
import Network
import OSLog

protocol ConnectionDelegate: AnyObject {
    func stateDidChange(to state: Connection.State)
    func received(_ message: InMessage)
}

class Connection {

    enum State: Equatable {
        case ready
        case waiting(String)
        case error(String)
        case ended
    }

    /// Connection Logger
    private let log = Log("📶Connection")

    private let connection: NWConnection
    private let queue = DispatchQueue(label: "ConnectionQueue")
    weak var delegate: ConnectionDelegate?

    /// Create connection
    init(hostname: NWEndpoint.Host, port: NWEndpoint.Port, delegate: ConnectionDelegate? = nil) {
        connection = NWConnection(host: hostname, port: port, using: .tcp)
        self.delegate = delegate
    }

    /// Connection state changed
    private func stateDidChange(to state: NWConnection.State) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .waiting(let error):
                self?.log.error("Connection waiting, searching for other route: %@", error.localizedDescription)
                self?.delegate?.stateDidChange(to: .waiting(error.localizedDescription))
            case .ready:
                self?.log.info("Connection ready")
                self?.delegate?.stateDidChange(to: .ready)
            case .failed(let error):
                self?.log.error("Connection error: %@", error.localizedDescription)
                self?.connection.cancel()
                self?.delegate?.stateDidChange(to: .error(error.localizedDescription))
            case .cancelled:
                self?.log.info("Connection cancelled")
                self?.delegate?.stateDidChange(to: .ended)
            default:
                break
            }
        }
    }

    /// Receive message 3-byte header
    private func receiveHeader() {

        connection.receive(minimumIncompleteLength: 3, maximumLength: 3)
        { [weak self] (data, _, isComplete, error) in
            // swiftlint:disable:previous opening_brace

            // Message complete
            if isComplete {
                self?.log.debug("Server finished sending messages")
                self?.stop()
            }

            // Received error
            else if let error = error {
                self?.log.error("Error receiving data: %@", error.localizedDescription)
                self?.stop()
            }

            // Received data
            if let data = data {
                let type = MessageType(rawValue: data[0]) ?? .unknown
                let length = UInt16(bigEndian: Data(data[1...2]))

                // Message without body
                if length == 0 {
                    self?.parse(message: Message(type: type, data: data))

                    if !isComplete && error == nil {
                        self?.receiveHeader()
                    }
                } else {
                    self?.receiveBody(type: type, length: length)
                }

            }

        }
    }

    /// Receive message body
    private func receiveBody(type: MessageType, length: UInt16) {

        connection.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length))
        { [weak self] (data, _, isComplete, error) in
            // swiftlint:disable:previous opening_brace

            // Received data
            if let data = data {
                self?.parse(message: Message(type: type, data: data))
            }

            // Message complete
            if isComplete {
                self?.log.debug("Server finished sending messages")
                self?.stop()
            }
            // Received error
            else if let error = error {
                self?.log.error("Error receiving data: %@", error.localizedDescription)
                self?.stop()
            }
            // Everything OK, can wait for next message
            else {
                self?.receiveHeader()
            }

        }
    }

    /// Parse the message and send to the delegate
    private func parse(message raw: Message) {
        if let message = InMessage(raw) {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.received(message)
            }
        } else {
            log.info("Received message that cannot be decoded (type: %x)", raw.type.rawValue)
        }
    }

    /// Start the connection
    func start() {
        connection.stateUpdateHandler = stateDidChange(to:)
        connection.start(queue: queue)
        receiveHeader()
    }

    /// Stop the connection
    func stop() {
        connection.cancel()
        log("Connection stopped")
    }

    /// Send a message
    /// - Parameter message: Message to be send
    func send(_ message: Message) {
        var data = Data()
        data.append(message.type.rawValue)

        if let messageData = message.data {
            data += UInt16(messageData.count).bigEndianData
            data += messageData
        } else {
            data += UInt16(0).bigEndianData
        }

        // Sending the data
        connection.send(content: data, completion: .contentProcessed({ [weak self] error in
            if let error = error {
                self?.log.error("Error sending message of type '%@': %@",
                                String(describing: message.type), error.localizedDescription)

                return
            } else {
                // Dane udało się wysłać
                self?.log.debug("Message of type '%@' sent", String(describing: message.type))
            }
        }))

    }

}
