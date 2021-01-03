//
//  AppDelegate.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 14/12/2020.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var navigation: Navigation!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        navigation = Navigation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }


}

