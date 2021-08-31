//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by James Lorenzo on 8/26/21.
//

import SwiftUI

@main
struct CryptoTracker: App {
    // todo - store symbol api call in coredata
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
