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
    private var homeWindow: NSWindow?
    private var roomWindow: NSWindow?
    private var gameWindow: NSWindow?

    private var lastRect: NSRect?

    private let log = Log("🧭Navigation")
    private var connection: Connection?
    private var playerID: Player.ID?
    private var possibleSettings: PossibleRoomSettings?

    init() {
        // Show 'Connect' window first
        makeConnectWindow()
    }

    /// Make a connect window
    private func makeConnectWindow(with error: String? = nil) {
        let viewModel = ConnectViewModel(error)
        viewModel.delegate = self

        let window = NSWindow(
            contentRect:NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)

        window.isReleasedWhenClosed = false
        window.title = "Wisielec — połącz"
        window.center()
        window.setFrameAutosaveName("HangmanConnect")
        window.contentView = NSHostingView(rootView:  ConnectView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
        connectWindow = window

    }

    /// Make a home window
    private func makeHomeWindow(with error: String? = nil) {
        let viewModel = HomeViewModel(connection!, possibleSettings: possibleSettings)
        viewModel.delegate = self

        let window = NSWindow(
            contentRect: lastRect ?? NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)

        window.isReleasedWhenClosed = false
        window.title = "Wisielec"
        window.center()
        window.setFrameAutosaveName("HangmanMain")
        window.contentView = NSHostingView(rootView:  HomeView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
        homeWindow = window
    }

    /// Make a room window
    private func makeRoomWindow(with playerID: Player.ID, status initialStatus: RoomStatus) {
        let viewModel = RoomViewModel(connection!, playerID: playerID, initialStatus: initialStatus)
        viewModel.delegate = self

        let window = NSWindow(
            contentRect: lastRect ?? NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)

        window.isReleasedWhenClosed = false
        window.title = "Wisielec — pokój"
        window.center()
        window.setFrameAutosaveName("HangmanRoom")
        window.contentView = NSHostingView(rootView:  RoomView(viewModel: viewModel))
        window.makeKeyAndOrderFront(nil)
        roomWindow = window
    }
}

extension Navigation: ConnectDelegate {

    func connected(connection: Connection) {
        log.debug("Connected to the server")
        self.connection = connection

        connectWindow?.close()
        connectWindow = nil

        makeHomeWindow()
    }

}

extension Navigation: HomeDelegate {

    func loggedIn(with playerID: Player.ID) {
        log.debug("Player logged in with id = %d", playerID)
        self.playerID = playerID
    }

    func receivedSettings(possibleSettings: PossibleRoomSettings) {
        log.debug("Player received possible room settings")
        self.possibleSettings = possibleSettings
    }

    func disconnected() {
        log.debug("Disconnected from the server")
        self.connection = nil

        homeWindow?.close()
        homeWindow = nil

        makeConnectWindow(with: "Utracono połączenie")
    }

    func inRoom(with playerID: Player.ID, status: RoomStatus) {
        log.debug("Player inside a room")

        lastRect = homeWindow?.frame
        homeWindow?.close()
        homeWindow = nil

        makeRoomWindow(with: playerID, status: status)
    }

    func inGame(with status: GameStatus) {
        log.debug("Player in game")

        // TODO: Handle in-game
    }

}

extension Navigation: RoomDelegate {

    func left() {
        log.debug("Player left the room")

        lastRect = roomWindow?.frame
        roomWindow?.close()
        roomWindow = nil

        makeHomeWindow()
    }

    func kicked() {
        log.debug("Player was kicked from the room")

        lastRect = roomWindow?.frame
        roomWindow?.close()
        roomWindow = nil

        makeHomeWindow(with: "Zostałeś wyrzucony z pokoju")
    }


}
