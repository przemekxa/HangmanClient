//
//  CreateRoom.swift
//  ExampleUI
//
//  Created by Przemek Ambroży on 04/12/2020.
//

import SwiftUI

struct CreateRoom: View {

    @State
    private var language = "pl"

    @State
    private var wordLength = 10.0

    @State
    private var gameLength = 80.0

    @State
    private var healthPoints = 2

    @State
    private var maxPlayers = 2.0

    var body: some View {
        VStack {
            Text("Utwórz pokój")
                .font(.headline)

            Text("Utwórz i skonfiguruj nowy pokój.")
                .padding(.bottom, 16.0)

            VStack {
                Picker("🌐 Język", selection: $language) {
                    Text("🇵🇱 Polski").tag("pl")
                    Text("🇬🇧 Angielski").tag("en")
                }

                HStack(alignment: .center, spacing: 8.0) {
                    Slider(value: $wordLength,
                           in: 5...30,
                           step: 1.0,
                           label: { Text("🔢 Długość słowa") })
                    Text("\(Int(wordLength)) liter")
                        .frame(width: 64.0, alignment: .trailing)
                }

                HStack(alignment: .center, spacing: 8.0) {
                    Slider(value: $gameLength,
                           in: 60...300,
                           label: { Text("⏰ Długość gry") })
                    Text(gameLengthString())
                        .frame(width: 64.0, alignment: .trailing)

                }

                Picker("❤️ Punkty zdrowia", selection: $healthPoints) {
                    ForEach(2..<5) { i in
                        Text("\(i) punkty zdrowia").tag(i)
                    }
                }

                HStack(alignment: .center, spacing: 8.0) {
                    Slider(value: $maxPlayers,
                           in: 2...5,
                           step: 1.0,
                           label: { Text("👤 Maksymalna liczba graczy") })
                    Text("\(Int(maxPlayers)) graczy")
                        .frame(width: 64.0, alignment: .trailing)
                }

            }
            .padding(.bottom, 8.0)

            Button("Utwórz pokój") {
                print("Kliknięto Dołącz")
            }
            .padding(.top, 8.0)

        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16.0)
    }

    private func gameLengthString() -> String {
        let all = Int(floor(gameLength))
        let seconds = all % 60
        let minutes = all / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CreateRoom_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoom()
            .frame(width: 800.0, height: 600.0)
    }
}
