//
//  AppDelegate.swift
//  inviteearndemo
//
//  Created by Michael Hathi on 18/05/22.
//

import UIKit
import FlyyFramework
import FirebaseCore
import FirebaseMessaging


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        //TODO: Config 1: Paste Package name from "Settings > Connect SDK" in Dashboard.
        Flyy.sharedInstance.setPackage(packageName: "package_name")
        //TODO: Config 2: Paste Partner Id from "Settings > SDK Keys" in Dashboard.
        Flyy.sharedInstance.initSDK(partnerToken: "partner_id", environment: Flyy.FLYY_ENVIRONMENT_STAGING)
        Messaging.messaging().delegate = self
        self.registerremorenotification()
        return true
    }
    
    func registerremorenotification()
    {
        if #available(iOS 10.0, *)
        {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }
        else
        {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        /*Fabric.sharedSDK().debug = true*/
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate : UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping
                                () -> Void)
    {
        let userInfo = response.notification.request.content.userInfo
        if let notificationSource = userInfo["notification_source"]
        {
            if notificationSource as! String == "flyy_sdk"
            {
                Flyy.sharedInstance.handleBackgroundNotification(userInfo: userInfo)
            }
        }
        completionHandler()
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if let notificationSource = userInfo["notification_source"]
        {
            if notificationSource as! String == "flyy_sdk"
            {
                Flyy.sharedInstance.handleForegroundNotification(userInfo: userInfo)
            }
        }
        completionHandler([[.alert, .sound]])
    }
}

// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate
{
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?)
    {
        print("Firebase registration token: \(fcmToken)")
        let token = fcmToken!
        if (!token.isEmpty) {
            Flyy.sharedInstance.sendFcmTokenToServer(fcmToken: token)
        }
        let dataDict:[String: String?] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
