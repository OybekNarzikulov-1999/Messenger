//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SDWebImage

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let completion: (() -> Void)?
}

private let reuseID = "reuseID"

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var data = [ProfileViewModel]()
    
    private let tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier )
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
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",
                                     completion: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No email")",
                                     completion: nil))
        
        data.append(ProfileViewModel(viewModelType: .logout,
                                     title: "Log Out",
                                     completion: { [weak self] in
            
            let actioSheet = UIAlertController(title: "Do you wanna log out?", message: nil, preferredStyle: .actionSheet)
            actioSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                
                guard let strongSelf = self else {return}
                
                UserDefaults.standard.set(nil, forKey: "email")
                UserDefaults.standard.set(nil, forKey: "name")
                
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
            self?.present(actioSheet, animated: true)
            
        }))
        
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
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
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
        
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                profileImage.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        return headerView
    }
    
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].completion?()
        
    }
    
}


class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(_ model: ProfileViewModel){
        switch model.viewModelType {
        case .info:
            self.textLabel?.text = model.title
            self.textLabel?.textAlignment = .left
            self.selectionStyle = .none
        case .logout:
            self.textLabel?.text = model.title
            self.textLabel?.textColor = .red
            self.textLabel?.textAlignment = .center
        }
    }
    
}
