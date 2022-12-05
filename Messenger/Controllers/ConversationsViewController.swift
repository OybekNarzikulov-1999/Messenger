//
//  ViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    // MARK: -  Properties
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
    }
    
    // MARK: - Helper Methods
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

}

