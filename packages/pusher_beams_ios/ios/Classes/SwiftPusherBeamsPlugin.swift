import Flutter
import UIKit
import PushNotifications

public class SwiftPusherBeamsPlugin: FlutterPluginAppLifeCycleDelegate, FlutterPlugin, PusherBeamsApi, InterestsChangedDelegate {
    
    static var callbackHandler : CallbackHandlerApi? = nil
    
    var interestsDidChangeCallback : String? = nil
    var messageDidReceiveInTheForegroundCallback : String? = nil
    
    var beamsClient : PushNotifications?
    var started : Bool = false
    var deviceToken : Data? = nil
    var data: [String: NSObject]?


    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let instance : SwiftPusherBeamsPlugin = SwiftPusherBeamsPlugin()
      
        callbackHandler = CallbackHandlerApi(binaryMessenger: messenger)
        PusherBeamsApiSetup(messenger, instance)
        
        UNUserNotificationCenter.current().delegate = instance
        registrar.addApplicationDelegate(instance)
    }
    
    override public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if(started) {
            beamsClient?.registerDeviceToken(deviceToken)
            print("SwiftPusherBeamsPlugin: registerDeviceToken with token: \(String(describing: deviceToken))")

        } else {
            self.deviceToken = deviceToken
        }
    }

    @nonobjc public override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("application.didReceiveRemoteNotification: \(userInfo)")
        beamsClient?.handleNotification(userInfo: userInfo)
    }

    public override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        print("SwiftPusherBeamsPlugin: didFinishLaunchingWithOptions with options: \(String(describing: launchOptions))")
        
        if launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            let remoteNotif = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as! [String: Any]
            let extraData = remoteNotif["data"] as? [String: Any]
            data = extraData?["info"] as? [String: NSObject]
            print("SwiftPusherBeamsPlugin: got initial data: \(String(describing: data))")
        } else {
            data = nil
        }
                        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func startInstanceId(_ instanceId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        beamsClient = PushNotifications(instanceId: instanceId)
        beamsClient?.delegate = self
        beamsClient?.start()

        if(deviceToken != nil) {
            beamsClient?.registerDeviceToken(deviceToken!)
            print("SwiftPusherBeamsPlugin: registerDeviceToken with token: \(String(describing: deviceToken))")
            deviceToken = nil
        }
        started = true

        beamsClient?.registerForRemoteNotifications()
    }

    public func addDeviceInterestInterest(_ interest: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.addDeviceInterest(interest: interest)
    }

    public func removeDeviceInterestInterest(_ interest: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.removeDeviceInterest(interest: interest)
    }
    
    public func getInitialMessage(completion: @escaping ([String : NSObject]?, FlutterError?) -> Void) {
        completion(data, nil)
    }

    public func getDeviceInterestsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> [String]? {
        return beamsClient!.getDeviceInterests()
    }

    public func setDeviceInterestsInterests(_ interests: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.setDeviceInterests(interests: interests)
    }

    public func clearDeviceInterestsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.clearDeviceInterests()
    }
    
    public func interestsSetOnDeviceDidChange(interests: [String]) {
        if (interestsDidChangeCallback != nil && (SwiftPusherBeamsPlugin.callbackHandler != nil)) {
            SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(interestsDidChangeCallback!, callbackName: "onInterestChanges", args: [interests], completion: {_ in
                print("SwiftPusherBeamsPlugin: interests changed: \(interests)")
            })
        }
    }

    public func onInterestChangesCallbackId(_ callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        interestsDidChangeCallback = callbackId
    }

    public func setUserIdUserId(_ userId: String, provider: BeamsAuthProvider, callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let tokenProvider = BeamsTokenProvider(authURL: provider.authUrl!) { () -> AuthData in
            let headers = provider.headers ?? [:]
            let queryParams: [String: String] = provider.queryParams ?? [:]
            return AuthData(headers: headers, queryParams: queryParams)
        }
        
        beamsClient!.setUserId(userId, tokenProvider: tokenProvider, completion: { error in
            guard error == nil else {
                SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(callbackId, callbackName: "setUserId", args: [error.debugDescription], completion: {_ in
                  print("SwiftPusherBeamsPlugin: callback \(callbackId) handled with error")
                })
                return
            }

            SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(callbackId, callbackName: "setUserId", args: [], completion: {_ in
                print("SwiftPusherBeamsPlugin: callback \(callbackId) handled")
            })
        })
    }

    public func clearAllStateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        beamsClient!.clearAllState {
            print("SwiftPusherBeamsPlugin: state cleared")
        }
    }

    public func stopWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        beamsClient!.stop {
            print("SwiftPusherBeamsPlugin: stopped")
        }
        started = false
    }
    
    public func onMessageReceived(inTheForegroundCallbackId callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        messageDidReceiveInTheForegroundCallback = callbackId
    }
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if (messageDidReceiveInTheForegroundCallback != nil && SwiftPusherBeamsPlugin.callbackHandler != nil) {
            let pusherMessage: [String : Any] = [
                "title": notification.request.content.title,
                "body": notification.request.content.body,
                "data": notification.request.content.userInfo["data"]
            ]
            
            SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(messageDidReceiveInTheForegroundCallback!, callbackName: "onMessageReceivedInTheForeground", args: [pusherMessage], completion: {_ in
                print("SwiftPusherBeamsPlugin: message received: \(pusherMessage)")
            })
        }
    }

    public override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                                    didReceive response: UNNotificationResponse, 
                                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        
            guard let userInfo = response.notification.request.content.userInfo as? [String: Any] else { return }
                        
            print("Received notification. UserInfo: \(userInfo)")
            
            // Debug: Print the type of userInfo
            print("Type of userInfo: \(type(of: userInfo))")
            
            // Debug: Print all keys in userInfo
            print("Keys in userInfo: \(userInfo.keys)")
                 
            if let notificationData = userInfo["data"] as? [String: Any] {
                print("Notification data found: \(notificationData)")
                
                if let info = notificationData["info"] as? [String: NSObject] {
                    // Set the data field
                    self.data = info
                    print("SwiftPusherBeamsPlugin: Notification data set: \(String(describing: self.data))")
                } else {
                    print("Failed to cast 'info' to [String: NSObject]")
                    print("Type of 'info': \(type(of: notificationData["info"]))")
                }
            } else {
                print("No 'data' key found in userInfo, or it's not a dictionary")
            }
            
            // Call the completion handler
            completionHandler()
        }
    
}
