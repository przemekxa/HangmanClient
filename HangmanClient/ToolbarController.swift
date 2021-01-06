//
//  ToolbarController.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 05/01/2021.
//

import Cocoa

class ToolbarController: NSObject, NSToolbarDelegate {

    enum ToolbarState {
        case none
        case inRoom
        case inRoomHost
        case inScoreboard
    }

    private static let disconnect = NSToolbarItem.Identifier("Disconnect")
    var state: ToolbarState = .none
    private var startGameEnabled = false

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        switch state {
        case .inRoom:
            return [.leaveRoom]
        case .inRoomHost:
            return [.leaveRoom, .startGame]
        case .inScoreboard:
            return [.goBack]
        default:
            return []
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarAllowedItemIdentifiers(toolbar)
    }

    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.isBordered = true
        item.isEnabled = true
        item.action = #selector(sendAction(_:))
        item.target = self
        item.autovalidates = true

        switch itemIdentifier {
        case .leaveRoom:
            item.label = "Opuść pokój"
            item.image = NSImage(named: NSImage.stopProgressTemplateName)
            return item
        case .startGame:
            item.label = "Graj"
            item.image = NSImage(named: NSImage.goForwardTemplateName)
            return item
        case .goBack:
            item.label = "Wróć"
            item.image = NSImage(named: NSImage.goBackTemplateName)
            return item
        default:
            return nil
        }
    }

    @objc private func sendAction(_ sender: NSToolbarItem) {
        switch sender.itemIdentifier {
        case .leaveRoom:
            NotificationCenter.default.post(name: .leaveRoom, object: nil)
        case .startGame:
            NotificationCenter.default.post(name: .startGame, object: nil)
        case .goBack:
            NotificationCenter.default.post(name: .goBack, object: nil)
        default:
            break
        }
    }
}

extension NSToolbarItem.Identifier {

    /// "Leave room" item
    static let leaveRoom = Self("leaveRoom")

    /// "Start game" item
    static let startGame = Self("startGame")

    /// "Back" item
    static let goBack = Self("goBack")
}

extension Notification.Name {

    /// "Leave room" item
    static let leaveRoom = Self("leaveRoom")

    /// "Start game" item
    static let startGame = Self("startGame")

    /// "Back" item
    static let goBack = Self("goBack")
}
