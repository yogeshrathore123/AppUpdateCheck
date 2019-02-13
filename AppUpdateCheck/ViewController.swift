//
//  ViewController.swift
//  AppUpdateCheck
//
//  Created by Yogesh Rathore on 12/02/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    enum VersionError: Error {
        case invalidBundleInfo
        case invalidResponse
    }
    
    // let currentAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    var latestAppVersion = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func checkUpdateBtnAction(_ sender: Any) {
        DispatchQueue.global().async {
            do {
                let update = try self.isUpdate()
                
                print("update",update)
                DispatchQueue.main.async {
                    if update.0 {
                        self.popupUpdateDialogue(type: update.1);
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    func isUpdate() throws -> (Bool, String) {
        guard let info = Bundle.main.infoDictionary,
            let currentAppVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String else {
                throw VersionError.invalidBundleInfo
        }
        if let path = Bundle.main.path(forResource: "test", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                    let dataResult = jsonResult["results"] {
                    // do stuff
                    print("jsonResult \(dataResult)")
                    latestAppVersion = dataResult["version"] as! String
                    print("App Version \(latestAppVersion)")
                    
                    print("version in app store", latestAppVersion,currentAppVersion);
                    
                    let typeofupdate = dataResult["typeofupdate"] as! String
                    return (latestAppVersion != currentAppVersion, typeofupdate)
                    
                }
            } catch {
                // handle error
                throw VersionError.invalidResponse
            }
        }
        throw VersionError.invalidResponse
    }
    
    func isUpdateAvailable() throws -> (Bool, String) {
        guard let info = Bundle.main.infoDictionary,
            let currentAppVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any]{
            latestAppVersion = result["version"] as! String
            print("version in app store", latestAppVersion,currentAppVersion);
            let typeofupdate = result["typeofupdate"] as! String
            return (latestAppVersion != currentAppVersion, typeofupdate)
        }
        throw VersionError.invalidResponse
        
    }
    
    // Mark: This update function will work for Apple App Store
    //    func isUpdateAvailable() throws -> Bool {
    //        guard let info = Bundle.main.infoDictionary,
    //            let currentAppVersion = info["CFBundleShortVersionString"] as? String,
    //            let identifier = info["CFBundleIdentifier"] as? String,
    //            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
    //                throw VersionError.invalidBundleInfo
    //        }
    //        let data = try Data(contentsOf: url)
    //        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
    //            throw VersionError.invalidResponse
    //        }
    //        if let result = (json["results"] as? [Any])?.first as? [String: Any],
    //            let version = result["version"] as? String {
    //            print("version in app store", version,currentAppVersion);
    //
    //            return version != currentAppVersion
    //        }
    //        throw VersionError.invalidResponse
    //
    //    }
    
    func popupUpdateDialogue(type: String){
        let alertMessage = "A new version of MyRide Application is available,Please update to version "+latestAppVersion;
        let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        // Mark: here url is your itunes app url
        let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "https://apple.com"),
                
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:"Skip this Version" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        if type == "force" {
            alert.addAction(okBtn)
        }else {
            alert.addAction(okBtn)
            alert.addAction(noBtn)
            
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

