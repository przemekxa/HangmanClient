//
//  GameViewModel.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 05/01/2021.
//

import Foundation
import Combine

protocol GameDelegate: AnyObject {
    func disconnected()
    func scoreboard(players: [PlayerScoreboard])
}

class GameViewModel: ObservableObject {

    // State
    @Published var you: PlayerInGame!
    @Published var players: [PlayerInGame]!
    @Published var word: [Character?]!
    @Published var remainingTime: String!
    private var endTime: Date!

    private let log = Log("🎮GameVM")
    private var connection: Connection
    weak var delegate: GameDelegate?
    private let playerID: Player.ID

    private let formatter = DateComponentsFormatter()
    private var timer: AnyCancellable?

    init(_ connection: Connection, playerID: Player.ID, initialStatus status: GameStatus) {
        self.connection = connection
        self.playerID = playerID
        self.connection.delegate = self

        // Setup formatter
        formatter.unitsStyle = .abbreviated

        update(with: status)
    }

    /// Update all values from game state
    /// - Parameter status: Game status
    private func update(with status: GameStatus) {

        // Update game state
        you = status.players.first { $0.id == playerID }!
        players = status.players.filter { $0.id != playerID }
        word = status.word
        endTime = status.endTime
        remainingTime = formatter.string(from: Date(), to: endTime) ?? "-"

        // Update timer
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .current, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .map { [weak self] now -> String in
                guard let self = self, now < self.endTime else { return "-" }
                return self.formatter.string(from: now, to: self.endTime) ?? "-"
            }
            .sink { [weak self] time in
                self?.remainingTime = time
            }
    }

    /// Guess a letter or a word
    /// - Parameter text: A letter (1 character) or a word (more than 1 character)
    func guess(_ text: String) {
        if text.count == 1, let letter = text.first {
            connection.send(.guess(letter: letter))
        } else {
            connection.send(.guess(word: text))
        }
    }

}

extension GameViewModel: ConnectionDelegate {

    func stateDidChange(to state: Connection.State) {
        log.debug("State did change to: %@", String(describing: state))
        if state != .ready {
            delegate?.disconnected()
        }
    }

    func received(_ message: InMessage) {
        log.debug("Received message: %@", String(describing: message))
        switch message {
        case .gameStatus(let status):
            update(with: status)
        case .scoreboard(let scoreboard):
            delegate?.scoreboard(players: scoreboard)
        default:
            log.error("Message is not supported by this class")
        }
    }

}
