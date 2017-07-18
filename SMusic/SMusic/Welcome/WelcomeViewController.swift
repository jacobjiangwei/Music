//
//  WelcomeViewController.swift
//  SMusic
//
//  Created by Jacob on 7/16/17.
//

import UIKit
import MediaPlayer

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startAppleMusic(_ sender: Any) {
        AppleMusicManager.shared.checkPermissionChange()
    }
    
    
    func authorize() {
        guard MPMediaLibrary.authorizationStatus() == .notDetermined else {
            return
        }
        
        MPMediaLibrary.requestAuthorization { (_) in
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
