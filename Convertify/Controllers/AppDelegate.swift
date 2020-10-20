
import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var orientationLock = UIInterfaceOrientationMask.all
    public var userID:String?
    let notificationCenter = UNUserNotificationCenter.current()
    var appstate = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
         
        UNUserNotificationCenter.current().delegate = self
         
        let authOptions: UNAuthorizationOptions = [.alert, .sound]
         
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
        }
        
        //get application instance ID
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
           if let messageID = userInfo[gcmMessageIDKey] {
               print("Message ID: \(messageID)")
           }
            
           // Print full message.
           print(userInfo)
       }
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print("Firebase Message Data");
        print(userInfo)
        var title = "Test Title";
        var body = "Test body";
        if let aps = userInfo["aps"] as? [String: Any]
        {
            if let alert = aps["alert"] as? [String: Any]
            {
                title = alert["title"] as? String ?? ""
                body = alert["body"] as? String ?? ""
            }
            
        }
        if let type = userInfo["type"] as? NSString
        {
            if type == "displayed"
            {
                completionHandler([[.alert, .sound]])
                //scheduleNotification(title: title, body: body)
            }
            else if appstate == false {
                completionHandler([[.alert, .sound]])
            }
        }
        
        // Change this to your preferred presentation option
        //completionHandler(UNNotificationPresentationOptions.alert)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
         
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //scheduleNotification(title: "FCM Totken", body: "Token \(fcmToken)");
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
     
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("opened again")
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("app in foreground")
        appstate = true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("app in background")
        appstate = false
	if #available(iOS 10.0, *) {
             let center = UNUserNotificationCenter.current()
             center.removeAllDeliveredNotifications()
             center.removeAllPendingNotificationRequests()
          } else {
             application.cancelAllLocalNotifications()
          }
    }
    func scheduleNotification(title: String, body: String) {
        
        let content = UNMutableNotificationContent() // notification content
        let userActions = "User Actions"
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 0
        content.categoryIdentifier = userActions
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    

}



