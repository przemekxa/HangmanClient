//
//  PlayerCell.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import SwiftUI

struct PlayerCellView: View {

    var player: Player
    var hostFeatures: Bool
    var isYou: Bool

    var makeHost: (() -> Void)?
    var kick: (() -> Void)?

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(player.nick)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("(#" + String(player.id) + ")")
                            .font(.caption)
                    }
                    HStack {
                        if player.isHost {
                            Text("ZARZĄDCA")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 1)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        if isYou {
                            Text("TY")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 1)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Button("Wyrzuć", action: {
                        kick?()
                    })
                    Button("Zarządzaj", action: {
                        makeHost?()
                    })
                }
                .opacity( (hostFeatures && !isYou) ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8.0)
            .padding(.horizontal, 16.0)
            Divider()
        }
    }

}

struct PlayerCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCellView(player: Player(id: 123, nick: "Player test", isHost: true),
                       hostFeatures: true,
                       isYou: true)
    }
}
