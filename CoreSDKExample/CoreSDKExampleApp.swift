import SwiftUI
import GoogleMaps
import GooglePlaces
import Firebase
import OneSignalFramework
import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
    }
    
    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set OneSignal log level and initialize
       
        
        return true
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

// CoreSDKExampleApp.swift
import SwiftUI
import Firebase

@main
struct CoreSDKExampleApp: App {
    // Connect the custom AppDelegate
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) var appDelegate

    // Navigation object if needed
    @StateObject private var navigation = Navigation()

    init() {
        setupTabBarAppearance() // Configure tab bar appearance globally
    }

    var body: some Scene {
        WindowGroup {
            AppStartView(navigation: navigation)
        }
    }

    // Set up global tab bar appearance
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBlue // Set tab bar background color

        // Set colors for selected and unselected tab bar items
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// FirebaseNotificationDelegate.swift
import UIKit
import FirebaseAuth

class FirebaseNotificationDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
        } else {
            // Handle other notifications here if necessary
            completionHandler(.newData)
        }
    }
}

// FirebaseAppDelegate.swift
import UIKit
import Firebase
import UserNotifications

class FirebaseAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Configure Google Maps and Places
        GMSServices.provideAPIKey("AIzaSyBw9JY6UP4Iy5JjoZMfW66Le-otJJHWhvA")
        GMSPlacesClient.provideAPIKey("AIzaSyBw9JY6UP4Iy5JjoZMfW66Le-otJJHWhvA")
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)

        // OneSignal initialization
        OneSignal.initialize("07422e8c-bfc9-41df-83e2-27ab6f2ffe8f", withLaunchOptions: launchOptions)
        
        OneSignal.User.pushSubscription.optIn()
        // Request authorization for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
        
   

        

        
        // Request push notification permissions
        OneSignal.Notifications.requestPermission({ accepted in
                print("User accepted notifications: \(accepted)")
              }, fallbackToSettings: true)
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to Firebase Auth
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        // Handle other notifications if needed
        completionHandler(.newData)
    }

    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        completionHandler()
    }
}
