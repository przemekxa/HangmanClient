//
//  Navigation.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import Cocoa
import SwiftUI

class Navigation {

    private var connectWindow: NSWindow?
    private var mainWindow: NSWindow?
    private let toolbarController = ToolbarController()

    private let log = Log("🧭Navigation")
    private var connection: Connection?
    private var playerID: Player.ID?
    private var possibleSettings: PossibleRoomSettings?

    init() {
        // Show 'Connect' window first
        showConnectWindow()
    }

    /// Make a connect window
    private func showConnectWindow(with error: String? = nil) {
        let viewModel = ConnectViewModel(error)
        viewModel.delegate = self

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)

        window.isReleasedWhenClosed = false
        window.title = "Wisielec — połącz"
        window.center()
        window.setFrameAutosaveName("HangmanConnect")
        window.contentView = NSHostingView(rootView: ConnectView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
        connectWindow = window

    }

    /// Make a main window
    /// - Returns: The created main window
    private func makeMainWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("HangmanMain")
        let toolbar = NSToolbar()
        toolbar.delegate = toolbarController
        window.toolbar = toolbar

        mainWindow = window
        return window
    }

    /// Show a home window
    private func showHomeWindow(with error: String? = nil) {

        let viewModel = HomeViewModel(connection!, possibleSettings: possibleSettings, error: error)
        viewModel.delegate = self

        let window = mainWindow ?? makeMainWindow()

        window.toolbar = nil

        window.title = "Wisielec"
        window.contentView = NSHostingView(rootView: HomeView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
    }

    /// Show a room window
    private func showRoomWindow(status initialStatus: RoomStatus) {
        let viewModel = RoomViewModel(connection!, playerID: playerID!, initialStatus: initialStatus)
        viewModel.delegate = self

        let window = mainWindow ?? makeMainWindow()

        toolbarController.state = .inRoom
        let toolbar = NSToolbar()
        toolbar.delegate = toolbarController
        window.toolbar = toolbar

        window.title = "Wisielec — pokój"
        window.contentView = NSHostingView(rootView: RoomView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
    }

    /// Show an in-game window
    private func showGameWindow(status initialStatus: GameStatus) {
        let viewModel = GameViewModel(connection!, playerID: playerID!, initialStatus: initialStatus)
        viewModel.delegate = self

        let window = mainWindow ?? makeMainWindow()

        window.toolbar = nil

        window.title = "Wisielec — gra"
        window.contentView = NSHostingView(rootView: GameView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
    }

    /// Show a scoreboard window
    private func showScoreboardWindow(status: [PlayerScoreboard]) {
        let viewModel = ScoreboardViewModel(connection!, scoreboard: status)
        viewModel.delegate = self

        let window = mainWindow ?? makeMainWindow()

        toolbarController.state = .inScoreboard
        let toolbar = NSToolbar()
        toolbar.delegate = toolbarController
        window.toolbar = toolbar

        window.title = "Wisielec — wyniki"
        window.contentView = NSHostingView(rootView: ScoreboardView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
    }
}

extension Navigation: ConnectDelegate {

    // Connected to the server
    func connected(connection: Connection) {
        log.debug("Connected to the server")
        self.connection = connection

        connectWindow?.close()
        connectWindow = nil

        showHomeWindow()
    }

    // Disconnected from the server
    func disconnected() {
        log.debug("Disconnected from the server")
        self.connection = nil
        self.possibleSettings = nil

        mainWindow?.close()
        mainWindow = nil

        showConnectWindow(with: "Utracono połączenie")
    }

}

extension Navigation: HomeDelegate {

    // User logged in
    func loggedIn(with playerID: Player.ID) {
        log.debug("Player logged in with id = %d", playerID)
        self.playerID = playerID
    }

    // Received possible settings
    func receivedSettings(possibleSettings: PossibleRoomSettings) {
        log.debug("Player received possible room settings")
        self.possibleSettings = possibleSettings
    }

    // User joined a room
    func inRoom(with playerID: Player.ID, status: RoomStatus) {
        log.debug("Player inside a room")
        showRoomWindow(status: status)
    }

    // User in game
    func inGame(with status: GameStatus) {
        log.debug("Player in game")
        showGameWindow(status: status)
    }

}

extension Navigation: RoomDelegate {

    // User left the room
    func left() {
        log.debug("Player left the room")
        showHomeWindow()
    }

    // User was kicked from the room
    func kicked() {
        log.debug("Player was kicked from the room")
        showHomeWindow(with: "Zostałeś wyrzucony z pokoju")
    }

    // Host changed
    func hostChanged(isHost: Bool) {
        log.debug("Host changed to %@", isHost ? "true" : "false")
        toolbarController.state = isHost ? .inRoomHost : .inRoom
        
        if let toolbar = mainWindow?.toolbar {
            if isHost {
                if toolbar.items.count == 1 {
                    toolbar.insertItem(withItemIdentifier: .startGame, at: 1)
                }
            } else {
                if toolbar.items.count == 2 {
                    toolbar.removeItem(at: 1)
                }
            }
        }
    }

}

extension Navigation: GameDelegate {

    // The game has ended
    func scoreboard(players: [PlayerScoreboard]) {
        log.debug("Game ended")
        showScoreboardWindow(status: players)
    }

}

extension Navigation: ScoreboardDelegate {

    // Close the scoreboard
    func closeScoreboard() {
        log.debug("Close scoreboard")
        showHomeWindow()
    }

}
