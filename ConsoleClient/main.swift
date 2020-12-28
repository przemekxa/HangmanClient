//
//  main.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation
import Network
import Combine

extension UInt32 {

    /// Create from big endian data
    init(bigEndian data: Data) {
        self = Self(bigEndian: data.withUnsafeBytes { $0.load(as: Self.self) })
    }

    /// Convert to big endian data
    var bigEndianData: Data {
        var data = Data()
        var bigEndian = self.bigEndian
        withUnsafeBytes(of: &bigEndian) { data.append(contentsOf: $0) }
        return data
    }
}

extension UInt16 {

    /// Create from big endian data
    init(bigEndian data: Data) {
        self = Self(bigEndian: data.withUnsafeBytes { $0.load(as: Self.self) })
    }

    /// Convert to big endian data
    var bigEndianData: Data {
        var data = Data()
        var bigEndian = self.bigEndian
        withUnsafeBytes(of: &bigEndian) { data.append(contentsOf: $0) }
        return data
    }
}

enum MessageType: UInt8 {
    case unknown = 0x0
    case login = 0x10
    case loggedIn = 0x11
}

struct Message {
    let type: MessageType
    let data: Data

    init(_ type: MessageType, data: Data) {
        self.type = type
        self.data = data
    }
}

class Connection {

    private let connection: NWConnection
    private let queue = DispatchQueue(label: "Kolejka do echo")

    // State
    @Published
    var state: NWConnection.State?

    // Messages
    private var messagePublisher = PassthroughSubject<Message, Never>()
    var messages: AnyPublisher<Message, Never> { messagePublisher.eraseToAnyPublisher() }


    /// Konstruktor
    init(hostname: NWEndpoint.Host, port: NWEndpoint.Port) {
        connection = NWConnection(host: hostname, port: port, using: .tcp)
    }

    /// Rozpocznij połączenie
    func start() {

        // Funkcja, która będzie wywoływana przy zmianie stanu połączenia
        connection.stateUpdateHandler = stateDidChange(to:)

        // Uruchomienie połączenia na osobnej kolejce (nie w wątku głównym)
        connection.start(queue: queue)

        // Rozpoczęcie przyjmowania danych
        receiveHeader()
    }

    /// Zakończ połączenie
    func stop() {
        connection.cancel()
    }


    /// Nastąpiła zmiana stanu połączenia
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            print("Błąd łączenia, szukanie innej ścieżki: \(error.localizedDescription)")
        case .ready:
            print("Połączenie ustanowione")
        case .failed(let error):
            print("Błąd połączenia: \(error.localizedDescription)")
            connection.cancel()
        case .cancelled:
            print("Połączenie anulowane")
        default:
            break
        }
        self.state = state
    }

    /// Otrzymywanie danych
    private func receiveHeader() {

        connection.receive(minimumIncompleteLength: 3, maximumLength: 3) { [weak self] (data, context, isComplete, error) in

            // Serwer zakończył przesyłanie danych
            if isComplete {
                print("Serwer zakończył przesyłanie danych")
                self?.stop()
            }
            // Otrzymano błąd
            else if let error = error {
                print("Błąd otrzymywania danych: \(error.localizedDescription)")
                self?.stop()
            }

            // Otrzymano dane
            if let data = data {

                //print("Received data: \( Array(data) )")

                let type = MessageType(rawValue: data[0]) ?? .unknown
                let length = UInt16(bigEndian: Data(data[1...2]))

                if(length == 0) {
                    self?.messagePublisher.send(Message(type, data: Data()))

                    if(!isComplete && error == nil) {
                        self?.receiveHeader()
                    }
                } else {
                    self?.receiveBody(type: type, length: length)
                }

            }

        }
    }

    private func receiveBody(type: MessageType, length: UInt16) {

        connection.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length))
        { [weak self] (data, context, isComplete, error) in


            // Otrzymano dane
            if let data = data {
                self?.messagePublisher.send(Message(type, data: data))
                //print("Got body: \( Array(data) )")
            }

            // Serwer zakończył przesyłanie danych
            if isComplete {
                print("Serwer zakończył przesyłanie danych")
                self?.stop()
            }
            // Otrzymano błąd
            else if let error = error {
                print("Błąd otrzymywania danych: \(error.localizedDescription)")
                self?.stop()
            }
            else {
                self?.receiveHeader()
            }

        }
    }

    /// Wysyłanie danych
    func send(_ text: String) {

        // Zamiana tekstu na bajty
        let data = text.data(using: .utf8)!

        // Wysłanie danych
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Błąd wysyłania danych \(text) : \(error.localizedDescription)")
                return
            } else {
                // Dane udało się wysłać
            }
        }))
    }

    func send(_ message: Message) {
        var data = Data()
        data.append(message.type.rawValue)
        var length = UInt16(message.data.count).bigEndian
        withUnsafeBytes(of: &length) { data.append(contentsOf: $0) }
        data += message.data

        // Wysłanie danych
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Błąd wysyłania danych: \(error.localizedDescription)")
                return
            } else {
                // Dane udało się wysłać
            }
        }))

    }

}

class Controller {

    private var connection: Connection
    private var cancellables = Set<AnyCancellable>()

    var restorationID: UInt32?
    var loggedIn = false

    init() {
        connection = Connection(hostname: "127.0.0.1", port: 1234)

        // On connection
        connection.$state
            .compactMap { $0 }
            .filter { $0 == .ready }
            .sink { [weak self] _ in
                self?.login()
            }
            .store(in: &cancellables)

        // On 'Logged in' message
        connection.messages
            .filter { $0.type == .loggedIn }
            .filter { $0.data.count >= 4 }
            .map { UInt32(bigEndian: $0.data) }
            .sink { [weak self] id in
                self?.restorationID = id
                print("Logged in with restoration id: \(id)")
            }
            .store(in: &cancellables)

        // On any message
        connection.messages
            .sink { m in
                print("Received message of type \(m.type), data: \( Array(m.data) )")
            }
            .store(in: &cancellables)

        connection.start()
    }

    /// Login to the server
    private func login() {

        let restorationData = (restorationID != nil) ? restorationID!.bigEndianData : Data()
        print("Sending login message with restoration ID: \(restorationID)")
        connection.send(Message(.login, data: restorationData))
    }

}

let controller = Controller()
RunLoop.main.run()
