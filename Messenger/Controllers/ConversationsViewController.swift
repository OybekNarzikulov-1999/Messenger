//
//  ViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import FirebaseAuth

private let reuseID = "Cell"

class ConversationsViewController: UIViewController {

    // MARK: -  Properties
    
    private let tableView: UITableView = {
       
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tableView.isHidden = true
        return tableView
        
    }()
    
    private let noConversationsLabel: UILabel = {
       
        let label = UILabel()
        label.textColor = .gray
        label.text = "No Conversations"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
        
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    
    // MARK: - Selectors
    
    @objc private func didTapComposeButton(){
        let vc = NewConversationViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func configureTableView(){
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.isHidden = false
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell.textLabel?.text = "Hello World!!!"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = "Chat"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
