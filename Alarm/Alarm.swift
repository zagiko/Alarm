
import Foundation
import UserNotifications


struct Alarm {
    
    private var notificationId: String
    
    var date: Date
   
    init(notificationId: String? = nil, date: Date) {
        self.notificationId = notificationId ?? UUID().uuidString
        self.date = date
    }
    
    
    
    func schedule(completion: @escaping (Bool) -> ()) {
        authorizeIfNeeded { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Beep Beep"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = Alarm.notificationCategoryId
            
            let triggerDataComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: self.date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDataComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: self.notificationId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    } else {
                        Alarm.scheduled = self
                        completion(true)
                    }
                }
            }
        }
    }
    
    func unshedule() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        Alarm.scheduled = nil
    }
    
    private func authorizeIfNeeded(completion: @escaping (Bool) -> ()) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            
            switch settings.authorizationStatus {
                
            case .authorized:
                completion(true)
                
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.sound ], completionHandler: {
                    (granted, _) in
                    completion(granted)
                })
                
            case .denied, .provisional, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
                
            }
        }
    }
    
}



extension Alarm: Codable {
    static let notificationCategoryId = "AlarmNotification"
    static let snoozeActionID = "snooze"
    
    private static var alarmURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathExtension("ScheduledAlarm")
    
    static var scheduled: Alarm? {
        
        get {
            let decoder = JSONDecoder()
            if let dataDecode = try? Data(contentsOf: alarmURL),
               let decodedData = try? decoder.decode(Alarm.self, from:dataDecode) {
                return decodedData
            }
        return nil
            
        }
        
        set {
            let encoder = JSONEncoder()
            if let encoderData = try? encoder.encode(newValue) {
                try? encoderData.write(to: alarmURL, options: .noFileProtection)
            }
            if scheduled == nil {
                try? FileManager.default.removeItem(at: alarmURL)
            }
            NotificationCenter.default.post(name: .alarmUpdated, object: nil)
        }
    }
}


                                                   
                                                   
