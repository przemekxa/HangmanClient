//
//  Message.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

typealias RestorationID = UInt16


/// Type of the message
enum MessageType: UInt8 {
    case unknown = 0x0
    case login = 0x10
    case loggedIn = 0x11
}


struct Message {
    let type: MessageType
    let data: Data
}
