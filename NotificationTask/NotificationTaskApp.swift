//
//  NotificationTaskApp.swift
//  NotificationTask
//
//  Created by 間口秀人 on 2023/02/06.
//

import SwiftUI

@main
struct NotificationTaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView{
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(ViewModel())
            }
        }
    }
}
