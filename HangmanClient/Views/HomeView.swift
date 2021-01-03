//
//  HomeView.swift
//  ExampleUI
//
//  Created by Przemek Ambroży on 04/12/2020.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject
    var viewModel: HomeViewModel

    @State
    var selection = 0

    @State
    private var username = ""

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {

            VStack(alignment: .leading, spacing: 8.0) {

                Text("Wisielec")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.bottom, 16.0)

                Text("Zasady gry")
                    .font(.callout)

                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam bibendum tellus interdum, ornare turpis in, aliquet nulla. Suspendisse convallis eros a nisl placerat, ac laoreet elit molestie. Mauris ultrices leo lobortis augue semper, et egestas mauris scelerisque. Proin sagittis imperdiet mattis. Phasellus consequat nulla id ultrices vulputate. Morbi eros ex, faucibus vitae bibendum vitae, ultricies nec nulla. Sed ultricies ut purus id mattis. Aenean tristique, tellus in sagittis finibus, ipsum est elementum urna, sed scelerisque lectus velit ut lectus. Nam eget elit sodales, bibendum orci vitae, ultrices lorem. In viverra venenatis quam sed tempus.")
                    .padding(.bottom, 16.0)

                GroupBox(label: Text("Nazwa użytkownika"), content: {
                    TextField("Nazwa użytkownika", text: $viewModel.nick)
                        .padding(8.0)
                        .frame(maxWidth: .infinity)
                })

                if let error = viewModel.error {
                    GroupBox(label: Text("Błąd").foregroundColor(.red)) {
                        Text(error)
                            .frame(maxWidth: .infinity)
                    }
                }

                Spacer()
            }
            //.padding(8.0)

            TabView(selection: $selection) {
                JoinRoom(viewModel: viewModel)
                    .tabItem { Text("Dołącz do pokoju") }
                    .tag(0)
                if let settings = viewModel.possibleSettings {
                    CreateRoom(possibleSettings: settings, viewModel: viewModel)
                        .tabItem { Text("Utwórz nowy pokój") }
                        .tag(1)
                }
            }

        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel(Connection(hostname: "127.0.0.1", port: 1234)))
            .frame(width: 800.0, height: 600.0)
    }
}
