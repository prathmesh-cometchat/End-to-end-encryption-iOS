//
//  AppDelegate.swift
//  Demo
//
//  Created by CometChat Inc. on 16/12/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    var window: UIWindow?
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initialization()
        
    // MARK: - To set default theme, uncommented the commented line.
       CometChatTheme.defaultAppearance()
        let palette = Palette()
        palette.set(background: .white)
        palette.set(accent: .black)
        palette.set(primary: .blue)
        palette.set(error: .red)
        palette.set(success: .yellow)
        palette.set(secondary: .lightGray)
        palette.set(accent50: .white)
      
    
        let family = CometChatFontFamily(regular: "CourierNewPSMT", medium: "CourierNewPS-BoldMT", bold: "CourierNewPS-BoldMT")
        var typography = Typography()
        typography.overrideFont(family: family)
        
//        CometChatTheme(typography: typography, palatte: palette)
//        CometChatLocalize.set(locale: .french)
        
        if CometChat.getLoggedInUser() != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "home") as! Home
            let navigationController: UINavigationController = UINavigationController(rootViewController: mainVC)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.prefersLargeTitles = true
           
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [ .foregroundColor:  UIColor.label,.font: UIFont.boldSystemFont(ofSize: 20) as Any]
                navBarAppearance.shadowColor = .clear
                navBarAppearance.backgroundColor = .systemGray5
                navigationController.navigationBar.standardAppearance = navBarAppearance
                navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
                navigationController.navigationBar.isTranslucent = true
            }
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
    
        return true
        
       
    }
    
    
    
    func initialization() {
        if(AppConstants.APP_ID.contains("Enter") || AppConstants.APP_ID.contains("ENTER") || AppConstants.APP_ID.contains("NULL") || AppConstants.APP_ID.contains("null") || AppConstants.APP_ID.count == 0) {

        } else {
            let uikitSettings = UIKitSettings()
            uikitSettings.set(appID: AppConstants.APP_ID)
                .set(authKey: AppConstants.AUTH_KEY)
                .set(region: AppConstants.REGION)
//                .overrideAdminHost(AppConstants.ADMIN_HOST)
//                .overrideClientHost(AppConstants.CLIENT_HOST)
                .subscribePresenceForAllUsers()
                .build()
            
            CometChatUIKit.init(uiKitSettings: uikitSettings, result: {
                result in
                switch result {
                case .success(_):
                    CometChat.setSource(resource: "uikit-v4", platform: "ios", language: "swift")
                    break
                case .failure(let error):
                    print( "Initialization Error:  \(error.localizedDescription)")
                    print( "Initialization Error Description:  \(error.localizedDescription)")
                    break
                }
            })
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        CometChat.configureServices(.willResignActive)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CometChat.configureServices(.didEnterBackground)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        let authToken = ""
  
    }
}
