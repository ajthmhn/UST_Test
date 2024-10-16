//
//  ViewController.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import UIKit
import Network

class BaseNavigationController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        func networkCall(){
               let monitor = NWPathMonitor()
               monitor.pathUpdateHandler = { path in
                   if path.status != .satisfied {
                       DispatchQueue.main.async {
                           GoogleHelper.signOut()
                           DispatchQueue.main.async {
                               self.navigationController?.popToRootViewController(animated: false)
                           }
                       }
                   }
               }
               monitor.start(queue: DispatchQueue.global(qos: .background))
        }
    }

}

class LoginViewController: UIViewController, NetServiceBrowserDelegate {

    @IBOutlet var btnLogin : UIButton!

    var serviceBrowser: NetServiceBrowser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogin.isHidden = true
        
        Task{
            let success = try await GoogleHelper.signinSilently()
            if success == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: StryBrdIds.Home) as! HomeScreenViewController
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                btnLogin.isHidden = false
            }
        }
        
        requestForPermission()
    }
    
    func requestForPermission() {
        serviceBrowser = NetServiceBrowser()
        serviceBrowser?.delegate = self
        serviceBrowser?.searchForServices(ofType: "_airplay._tcp", inDomain: "")
    }
    
    @IBAction func btnSignin(_ sender: Any) {
        Task{
            let success = try await GoogleHelper.signin(sender: self)
            if success == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: StryBrdIds.Home) as! HomeScreenViewController
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
}
