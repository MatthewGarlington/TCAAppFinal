//
//  TCAAppFinalApp.swift
//  TCAAppFinal
//
//  Created by Matthew Garlington on 7/5/22.
//

import SwiftUI
//import Overture
import FavoritePrimeFramework
import ComposableArch

@main
struct TCAAppFinalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(
                initialValue: AppState(),
                reducer: logging(_appReducer)
            )
            )
            .preferredColorScheme(.light)
        }
    }
}
