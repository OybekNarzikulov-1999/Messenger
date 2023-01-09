//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

private let reuseID = "Cell"

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var data = ["Sign Out"]
    
    private let tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        return tableView
        
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        view.addSubview(tableView)
        
    }
    
    override func viewDidLayoutSubviews() {
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(0)
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func configureNavigationBar(){
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    func createTableHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        
        let safeEmail = DatabaseManager.shared.safeEmail(emailAddress: email)
        let filename = "\(safeEmail)_profile_picture.png"
        let path = "images/\(filename)"
                
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        
        let profileImage = UIImageView(frame: CGRect(x: (self.view.frame.width - 150) / 2, y: 25, width: 150, height: 150))
        profileImage.layer.cornerRadius = 75
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleToFill
        profileImage.backgroundColor = .white
        headerView.addSubview(profileImage)
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: profileImage, url: url)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL){
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {return}
            
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data )
            }
            
        }.resume()
    }
    
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actioSheet = UIAlertController(title: "Do you wanna log out?", message: nil, preferredStyle: .actionSheet)
        actioSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {return}
            
            // Facebook Log Out
            
            // Google Log Out
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
                
            } catch {
                print("Failed to log out")
            }
        }))
        actioSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actioSheet, animated: true)
        
    }
    
}
