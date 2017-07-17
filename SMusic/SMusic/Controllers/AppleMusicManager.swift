//
//  AppleMusicManager.swift
//  SMusic
//
//  Created by Jacob on 7/17/17.
//

import Foundation
import StoreKit
import MediaPlayer

final class AppleMusicManager {
    private init() {}
    static let shared = AppleMusicManager()
    
    
    let cloudServiceController = SKCloudServiceController()
    var cloudServiceCapabilities = SKCloudServiceCapability()
    var cloudServiceStorefrontCountryCode = ""
    var userToken = ""

    
    func authPermission() {
        requestMediaLibraryAuthorization()
        requestCloudServiceAuthorization()
    }
    
    func requestMediaLibraryAuthorization() {
        guard MPMediaLibrary.authorizationStatus() == .notDetermined else {
            return
        }
        
        MPMediaLibrary.requestAuthorization { (_) in
            print(MPMediaLibrary.authorizationStatus().rawValue)
        }
    }
    
    func requestCloudServiceAuthorization() {
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else { return }        
        SKCloudServiceController.requestAuthorization { [weak self] (authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                self?.requestCloudServiceCapabilities()
//                self?.requestUserToken()
            default:
                break
            }
        }
    }
    
    func requestCloudServiceCapabilities() {
        cloudServiceController.requestCapabilities(completionHandler: { [weak self] (cloudServiceCapability, error) in
            guard error == nil else {
                fatalError("An error occurred when requesting capabilities: \(error!.localizedDescription)")
            }
            self?.cloudServiceCapabilities = cloudServiceCapability
        })
    }
    
//    func requestUserToken() {
//        guard let developerToken = appleMusicManager.fetchDeveloperToken() else {
//            return
//        }
//
//        if SKCloudServiceController.authorizationStatus() == .authorized {
//
//            let completionHandler: (String?, Error?) -> Void = { [weak self] (token, error) in
//                guard error == nil else {
//                    print("An error occurred when requesting user token: \(error!.localizedDescription)")
//                    return
//                }
//
//                guard let token = token else {
//                    print("Unexpected value from SKCloudServiceController for user token.")
//                    return
//                }
//
//                self?.userToken = token
//
//                /// Store the Music User Token for future use in your application.
//                let userDefaults = UserDefaults.standard
//
//                userDefaults.set(token, forKey: AuthorizationManager.userTokenUserDefaultsKey)
//                userDefaults.synchronize()
//
//                if self?.cloudServiceStorefrontCountryCode == "" {
//                    self?.requestStorefrontCountryCode()
//                }
//
//                NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
//            }
//
//            if #available(iOS 11.0, *) {
//                cloudServiceController.requestUserToken(forDeveloperToken: developerToken, completionHandler: completionHandler)
//            } else {
//                cloudServiceController.requestPersonalizationToken(forClientToken: developerToken, withCompletionHandler: completionHandler)
//            }
//        }
//    }
}
