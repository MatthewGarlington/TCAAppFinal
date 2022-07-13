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
                NavigationLink(destination: CounterView(
                    store: self.store.view(
                        value:  { $0.counterView },
                        action:  { .counterView($0) }))
                    
                ) {
                    Text("Counter Demo")
                }
                
                NavigationLink { FavoritePrimeView(
                    store: store.view(
                        value: { $0.favoritePrimes },
                        action: { .favoritePrimes($0) })
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
        ContentView(store: .init(initialValue: AppState(), reducer: appReducer))
    }
}

struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var loggedInUser: User? = nil
  var activityFeed: [Activity] = []

  struct Activity {
    let timestamp: Date
    let type: ActivityType

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

enum AppAction {
  case counterView(CounterViewAction)
  case favoritePrimes(FavoritesPrimeActions)

  var favoritePrimes: FavoritesPrimeActions? {
    get {
      guard case let .favoritePrimes(value) = self else { return nil }
      return value
    }
    set {
      guard case .favoritePrimes = self, let newValue = newValue else { return }
      self = .favoritePrimes(newValue)
    }
  }

  var counterView: CounterViewAction? {
    get {
      guard case let .counterView(value) = self else { return nil }
      return value
    }
    set {
      guard case .counterView = self, let newValue = newValue else { return }
      self = .counterView(newValue)
    }
  }
}

extension AppState {
  var counterView: CounterViewState {
    get {
        CounterViewState(
        count: self.count,
        favorites: self.favoritePrimes,
        showAlert: self.counterView.showAlert
      )
    }
    set {
      self.count = newValue.count
      self.favoritePrimes = newValue.favorites
        self.counterView.showAlert = newValue.showAlert
    }
  }
}

let appReducer: (inout AppState, AppAction) -> [Effect<AppAction>] = combine(
    pullback(counterViewReducer, value: \.counterView, action: \.counterView),
    pullback(favoriteListReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

func activityFeed(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    
    return { state, action in
        switch action {
        case .counterView(.counter):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
            
        case .counterView(.primeModal(.saveFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        case .favoritePrimes(.loadFavoritePrimes(_)):
            break
        case .favoritePrimes(.savedButtonTapped):
            break
        case .favoritePrimes(.loadButtonTapped):
            break
        }
        
        reducer(&state, action)
    }
}
