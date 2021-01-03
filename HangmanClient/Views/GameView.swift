//
//  GameView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import SwiftUI

struct GameView: View {

    @State
    var players = [PlayerInGame(id: 123,
                                nick: "Gracz 1",
                                points: 45,
                                remainingHealth: 3,
                                guessed: false),
                   PlayerInGame(id: 456,
                                nick: "Gracz 2",
                                points: 1200,
                                remainingHealth: 1,
                                guessed: true),
    ]

    @State
    var guessed = ""

    var body: some View {
        HStack(alignment: .center, spacing: 0.0) {
            List(players, rowContent: playerCell)
                .listStyle(SidebarListStyle())
                .frame(maxWidth: 300.0)

            VStack(alignment: .center, spacing: 16.0) {
                Text("Gra")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack {
                    Text("Pozostały czas:")
                    Text("1:15")
                        .font(.headline)
                }

                GroupBox(label: Text("Słowo do odgadnięcia")) {

                    VStack(alignment: .center, spacing: 12.0) {
                        Text("Białe pola oznaczają miejsca, w których brakuje liter.")

                        WordView()
                            .padding(8.0)
                            .cornerRadius(8.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.0)
                                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                            )
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8.0)

                }

                GroupBox(label: Text("Odgadnij")) {

                    VStack(alignment: .center, spacing: 12.0) {

                        Text("Wpisz literę lub całe słowo, które chcesz odgadnąć")

                        TextField("Odgadywana litera lub słowo", text: $guessed)


                        Button(action: {}, label: {
                            Text(guessed.count <= 1 ? "Odgadnij literę" : "Odgadnij słowo")
                                .frame(minWidth: 100)
                        })
                        .disabled(guessed.count == 0)

                    }
                    .padding(8.0)
                }

                GroupBox(label: Text("Twoje statystyki")) {

                    VStack(alignment: .leading, spacing: 12.0) {

                        HStack {
                            Text("Punkty:")
                                .font(.headline)
                                .fontWeight(.regular)
                            Text(String(12))
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                        }

                        HStack {
                            Text("Życie:")
                                .font(.headline)
                                .fontWeight(.regular)
                            Text(String(repeating: "❤️", count: Int(3)))
                        }
                    }
                    .padding(8.0)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }

    private func playerCell(_ player: PlayerInGame) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(player.nick)
                    .font(.largeTitle)
                Text("(#" + String(player.id) + ")")
                    .font(.caption)
            }
            .padding(.top, 12.0)
            HStack {
                Text("Punkty:")
                    .font(.headline)
                    .fontWeight(.regular)
                Text(String(player.points))
                    .font(.headline)
                    .fontWeight(.bold)
            }
            HStack {
                Text("Życie:")
                    .font(.headline)
                    .fontWeight(.regular)
                Text(String(repeating: "❤️", count: Int(player.remainingHealth)))
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Odgadnięte hasło:")
                    .font(.headline)
                    .fontWeight(.regular)
                Text(player.guessed ? "✅ tak" : "nie")
                    .font(.headline)
                    .fontWeight(player.guessed ? .bold : .regular)
            }
            .padding(.bottom, 12.0)
            Divider()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .frame(width: 800, height: 600.0)
    }
}
