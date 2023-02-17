
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let noteCenter = UNUserNotificationCenter.current()
        
        let snozeAction = UNNotificationAction(identifier: Alarm.snoozeActionID, title: "Snzoe", options: [])
        
        let alarmCategory = UNNotificationCategory(identifier: Alarm.notificationCategoryId, actions: [snozeAction], intentIdentifiers: [], options: [])
        
        noteCenter.setNotificationCategories([alarmCategory])
        noteCenter.delegate = self
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == Alarm.snoozeActionID {
        
            let snoozeDate = Date().addingTimeInterval(9 * 60)
            
            let alarm = Alarm(date: snoozeDate)
            
            alarm.schedule { granted in
            
                if !granted {
                    print("Can't schedule snooze because notification permissions were revoked.")
                }
            }
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        Alarm.scheduled = nil
        
    }
    
}

