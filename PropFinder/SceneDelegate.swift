//
//  SceneDelegate.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 18/06/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            // 1. Ensure we have a valid UIWindowScene instance
            guard let windowScene = (scene as? UIWindowScene) else { return }
            
            // 2. Programmatically create the UIWindow bounded by the scene's screen coordinate space
            let window = UIWindow(windowScene: windowScene)
            
            // 3. Instantiate our initial blank ViewController (from your template file)
        // 1. Initialize the concrete remote and local storage structures
        let remoteSource = FirestoreRemoteDataSource()
        let repo = PropertyRepository(remoteDataSource: remoteSource)

        // 2. Inject repo into the state machine ViewModel
        let listViewModel = PropertyListViewModel(repository: repo)

        // 3. Inject ViewModel into your programmatic View Controller
        let rootVC = PropertyListViewController(viewModel: listViewModel)

        // 4. Wrap inside navigation control and apply to window
        window.rootViewController = UINavigationController(rootViewController: rootVC)// Ensures a clean canvas
            
            // 5. Retain the window context in our property and bring it to the forefront
            self.window = window
            window.makeKeyAndVisible()
        }
    
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

