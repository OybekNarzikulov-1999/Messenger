//
//  LoginViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit
import SnapKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseCore
import JGProgressHUD

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        
        let image = UIImageView()
        image.image = UIImage(named: "messenger")
        return image
        
    }()
    
    private let emailTextField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = "Email"
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textContentType = .emailAddress
        textField.returnKeyType = .continue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
        
    }()
    
    private let passwordTextField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = "Password"
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
        
    }()
    
    private let loginButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
        
    }()
    
    private lazy var facebookLoginButton: FBLoginButton = {
       
        let button = FBLoginButton()
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.frame.size = CGSize(width: view.frame.size.width - 60, height: 52)
        return button
        
    }()
    
    private lazy var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(googleButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.frame.size = CGSize(width: view.frame.size.width - 60, height: 52)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        dismissKeyboardWhenTappedAround()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height)
            make.width.equalTo(view.snp.width)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(70)
            make.centerX.equalTo(view)
            make.width.height.equalTo(150)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.height.equalTo(52)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        loginButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        facebookLoginButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        googleLoginButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(facebookLoginButton.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
    }
    
    // MARK: - Selectors
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @objc private func loginButtonTapped(){
        
        view.endEditing(true)
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty,
              password.count >= 6 else {
                  alertUserLoginError()
                  return
              }
        
        spinner.show(in: view)
        
        // Firebase LogIn
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let strongSelf = self else {return}
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard error == nil else {
                strongSelf.alertUserLoginError()
                return
                
            }
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result {
                case .success(let data):
                    
                    guard let firstName = data["first_name"] as? String,
                          let lastName = data["last_name"] as? String else {
                              return
                          }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                case .failure(let error):
                    print("Failed to geet data with error: \(error)")
                }
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("DEBUG: User logged in")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }

    }
    
    @objc func googleButtonPressed(){
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            guard error == nil else {return}
            
            guard let email = user?.profile?.email,
                  let firstName = user?.profile?.givenName,
                  let lastName = user?.profile?.familyName else {return}
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.shared.userExists(withEmail: email) { exists in
                if !exists {
                    // Insert user to database
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            // upload user
                            
                            if let _ = user?.profile?.hasImage {
                                
                                guard let imageUrl = user?.profile?.imageURL(withDimension: 200) else {return}
                                URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                                    guard let data = data else {return}
                                    let fileName = chatUser.profilePictureFilename
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                        switch result {
                                        case .success(let downloadUrl):
                                            
                                            UserDefaults.standard.set(downloadUrl, forKey: Constants.profileImageDowloadURL)
                                            print("\(downloadUrl)")
                                            
                                        case .failure(let error):
                                            
                                            print("StorageManager error: \(error)")
                                            
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                }
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if error != nil {
                    print("Failed to sign in with google")
                    return
                }
                // User is signed in
                print("DEBUG: User logged in")
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Helper Function
    
    func alertUserLoginError(){
        
        let alert = UIAlertController(title: "Ooops", message: "Please write information correctly to log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginButtonTapped()
        }
        
        return true
    }
    
}
