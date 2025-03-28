//
//  ViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 27/03/2025.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        handleNoAuthenticated()
    }
    
    private func handleNoAuthenticated() {
        // check the status
        if Auth.auth().currentUser == nil {
            // show login
            let loginVc = LoginViewController()
            loginVc.modalPresentationStyle = .fullScreen
            present(loginVc, animated: true)
        }
    }
}

