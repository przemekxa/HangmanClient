//
//  OutMessage.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

extension Message {

    /// Create 'Login' requets message
    static func login(_ restorationID: RestorationID? = nil) -> Self {
        let data = restorationID?.bigEndianData ?? Data()
        return Message(type: .login, data: data)
    }

}
