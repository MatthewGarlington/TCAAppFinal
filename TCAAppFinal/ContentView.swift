//
//  ContentView.swift
//  TCAAppFinal
//
//  Created by Matthew Garlington on 7/5/22.
//

import SwiftUI
import FavoritePrimeFramework
import PrimeModalFramework
import ComposableArch
import CounterFramework


struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    var body: some View {
        NavigationView {
            List {
                NavigationLink { CounterView(store: store.view(
                    value: { ($0.count, $0.favorites) },
                    action: {
                        switch $0 {
                        case let .counter(action):
                            return .counter(action)
                        case let .primeModal(action):
                            return .primeModal(action)
                        }
                    })
                )

                } label: {
                    Text("Counter demo")
                }
                
                NavigationLink { FavoritePrimeView(
                    store: store.view(
                        value: { $0.favorites },
                        action: { .favoritesList($0) })
                )
                } label: {
                    Text("Favorites primes")
                }
            }
        .navigationTitle("Counter Demo")
       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialValue: AppState(), reducer: _appReducer))
    }
}

struct AppState {
     var count = 0
     var favorites: [Int] = []
     var loggedInUser: User? = nil
     var activityFeed: [Activity] = []
    
    struct Activity {
        let timeStap: Date
        let type: ActivityType
        
        enum ActivityType {
            case addedFavoritesPrime(Int)
            case removedFavoritesPrime(Int)
        }
    }
    
    struct User {
        var id: Int
        var name: String
        var bio: String
    }
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritesList(FavoritesPrimeActions)
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }

        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModel: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }

        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }

    var favoritePrimes: FavoritesPrimeActions? {
        get {
            guard case let .favoritesList(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritesList = self, let newValue = newValue else { return }
            self = .favoritesList(newValue)
        }
    }
}


func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter:
            break
        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(.init(timeStap: Date(), type: .removedFavoritesPrime(state.count)))
            
        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(.init(timeStap: Date(), type: .addedFavoritesPrime(state.count)))
            
        case let .favoritesList(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timeStap: Date(), type: .removedFavoritesPrime(index)))
            }
        }
        reducer(&state, action)
    }
}

extension AppState {
    var primeModal: PrimeModalState {
        get {
            PrimeModalState(
                count: self.count,
                favorites: self.favorites
            )
        }
        set {
            self.count = newValue.count
            self.favorites = newValue.favorites
        }
    }
}

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModel),
    pullback(favoriteListReducer, value: \.favorites, action: \.favoritePrimes)
)


//let appReducer = combine(
//    pullback(_appReducer, value: \.self)
//)

