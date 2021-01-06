//
//  ScoreboardViewModel.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 05/01/2021.
//

import Foundation
import Combine

protocol ScoreboardDelegate: AnyObject {
    func disconnected()
    func closeScoreboard()
}

class ScoreboardViewModel {

    // State
    let scoreboard: [PlayerScoreboard]

    private let log = Log("💯ScoreboardVM")
    private var connection: Connection
    weak var delegate: ScoreboardDelegate?
    private var cancellables = Set<AnyCancellable>()

    init(_ connection: Connection, scoreboard: [PlayerScoreboard]) {
        self.connection = connection
        self.scoreboard = scoreboard
        self.connection.delegate = self

        NotificationCenter.default
            .publisher(for: .goBack)
            .sink { [weak self] _ in self?.back() }
            .store(in: &cancellables)

        log.debug("Init")
    }

    private func back() {
        delegate?.closeScoreboard()
    }

}

extension ScoreboardViewModel: ConnectionDelegate {

    func stateDidChange(to state: Connection.State) {
        log.debug("State did change to: %@", String(describing: state))
        if state != .ready {
            delegate?.disconnected()
        }
    }

    func received(_ message: InMessage) {
        log.debug("Received message: %@", String(describing: message))
        log.error("Receiving messages is not supported by this class")
    }

}
