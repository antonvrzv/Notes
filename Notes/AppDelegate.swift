//
//  AppDelegate.swift
//  Notes
//
//  Created by Anton Vorozhischev on 16.02.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        CoreDataManager.shared.loadPersistantStores {
            print("Data upload was successful from persistant store")
        }

        let notesListViewController = NotesListViewController()
        let navigationController = UINavigationController(rootViewController: notesListViewController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

