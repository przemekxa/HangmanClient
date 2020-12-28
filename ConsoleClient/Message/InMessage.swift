//
//  InMessage.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

enum InMessage {
    case loggedIn(RestorationID)

    /// Initialize incoming message from raw message
    init?(_ raw: Message) {
        var parsed: Self? = nil

        switch raw.type {
        case .loggedIn:
            parsed = Self.loggedIn(raw.data)
        default:
            break
        }

        if let message = parsed {
            self = message
        } else {
            return nil
        }
    }
}

extension InMessage {

    /// Parse 'Logged in' message
    private static func loggedIn(_ data: Data) -> Self? {
        if data.count == 2 {
            return .loggedIn(UInt16(bigEndian: data))
        }
        return nil
    }

}
