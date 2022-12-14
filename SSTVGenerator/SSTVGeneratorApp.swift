//
//  SSTVGeneratorApp.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/14/22.
//

import SwiftUI

@main
struct SSTVGeneratorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
