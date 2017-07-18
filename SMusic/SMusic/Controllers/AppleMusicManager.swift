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
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionChange), name: KeyCenter.authorizationDidUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionChange), name: KeyCenter.cloudServiceDidUpdateNotification, object: nil)
        
    }
    static let shared = AppleMusicManager()
    
    
    let cloudServiceController = SKCloudServiceController()
    var cloudServiceCapabilities = SKCloudServiceCapability()
    var cloudServiceStorefrontCountryCode = ""
    var userToken = ""
    
    @objc func checkPermissionChange() {
        if MPMediaLibrary.authorizationStatus() == .notDetermined  {
            requestMediaLibraryAuthorization()
            return
        }
        if SKCloudServiceController.authorizationStatus() == .notDetermined {
            requestCloudServiceAuthorization()
            return
        }
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            print("MPMediaLibrary not passed")
            return
        }
        
        guard SKCloudServiceController.authorizationStatus() == .authorized else {
            print("SKCloudServiceController not passed")
            return
        }
        
        requestCloudServiceCapabilities()
        if let token = UserDefaults.standard.string(forKey: KeyCenter.userTokenUserDefaultsKey) {
            userToken = token
        } else {
            /// The token was not stored previously then request one.
            requestUserToken()
        }
    }
    
    func requestMediaLibraryAuthorization() {
        if MPMediaLibrary.authorizationStatus() == .notDetermined {
            MPMediaLibrary.requestAuthorization { (_) in
                NotificationCenter.default.post(name: KeyCenter.authorizationDidUpdateNotification, object: nil)
            }
        }
        else
        {
            checkPermissionChange()            
        }
    }
    
    func requestCloudServiceAuthorization() {
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else {
            return
        }
        SKCloudServiceController.requestAuthorization { (_) in
            NotificationCenter.default.post(name: KeyCenter.cloudServiceDidUpdateNotification, object: nil)
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
    
    func requestUserToken() {
        if SKCloudServiceController.authorizationStatus() == .authorized {

            let completionHandler: (String?, Error?) -> Void = { [weak self] (token, error) in
                guard error == nil else {
                    print("An error occurred when requesting user token: \(error!.localizedDescription)")
                    return
                }

                guard let token = token else {
                    print("Unexpected value from SKCloudServiceController for user token.")
                    return
                }

                self?.userToken = token

                /// Store the Music User Token for future use in your application.
                let userDefaults = UserDefaults.standard

                userDefaults.set(token, forKey: KeyCenter.userTokenUserDefaultsKey)
                userDefaults.synchronize()

                if self?.cloudServiceStorefrontCountryCode == "" {
                    self?.requestStorefrontCountryCode()
                }

                NotificationCenter.default.post(name: KeyCenter.cloudServiceDidUpdateNotification, object: nil)
            }

            cloudServiceController.requestUserToken(forDeveloperToken: KeyCenter.developerToken, completionHandler: completionHandler)
        }
    }
    
    func requestStorefrontCountryCode() {
        let completionHandler: (String?, Error?) -> Void = { [weak self] (countryCode, error) in
            guard error == nil else {
                print("An error occurred when requesting storefront country code: \(error!.localizedDescription)")
                return
            }
            
            guard let countryCode = countryCode else {
                print("Unexpected value from SKCloudServiceController for storefront country code.")
                return
            }
            
            self?.cloudServiceStorefrontCountryCode = countryCode
            
            NotificationCenter.default.post(name: KeyCenter.cloudServiceDidUpdateNotification, object: nil)
        }
        
        if SKCloudServiceController.authorizationStatus() == .authorized {
            cloudServiceController.requestStorefrontCountryCode(completionHandler: completionHandler)
        }
    }
}
