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

    private var lastRect: NSRect?
    private var possibleSettings: PossibleRoomSettings?

    private let log = Log("🧭Navigation")
    private var connection: Connection?

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
    private func makeRoomWindow(with userID: Player.ID, status initialStatus: RoomStatus) {
        let viewModel = RoomViewModel(connection!, userID: userID, initialStatus: initialStatus)
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
        window.contentView = NSHostingView(rootView:  InRoomView(viewModel: viewModel))
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

    func receivedSettings(possibleSettings: PossibleRoomSettings) {
        self.possibleSettings = possibleSettings
    }

    func disconnected() {
        log.debug("Disconnected from the server")
        self.connection = nil

        homeWindow?.close()
        homeWindow = nil

        makeConnectWindow(with: "Utracono połączenie")
    }

    func inRoom(with userID: Player.ID, status: RoomStatus) {
        log.debug("Player inside a room")

        lastRect = homeWindow?.frame
        homeWindow?.close()
        homeWindow = nil

        makeRoomWindow(with: userID, status: status)
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
