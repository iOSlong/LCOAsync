//
//  AppDelegate.swift
//  LCOAsync
//
//  Created by xuewu1011@163.com on 08/27/2019.
//  Copyright (c) 2019 xuewu1011@163.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let vc:ViewController = ViewController()
        vc.title  = "gcd demo"
        
        
        if let file = Bundle.main.path(forResource: "SignType", ofType: "plist"){
            let plistInfos:NSArray =  NSArray(contentsOf: URL(fileURLWithPath: file))! as NSArray
            
            let models:NSMutableArray = NSMutableArray.init()
            for sections in plistInfos {
                let rows:NSMutableArray = NSMutableArray.init()
                for item in (sections as! NSArray) {
                    let model:LCSignModel = LCSignModel.deserialize(from: (item as! NSDictionary))!
                    rows.add(model)
                }
                models.add(rows)
            }
            vc.dataSource = models
        } else {
            print("file SignType.plist can't be find!")
        }
        
        
        
        let nav:UINavigationController = UINavigationController.init(rootViewController: vc)
        
        self.window?.rootViewController = nav
        
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

