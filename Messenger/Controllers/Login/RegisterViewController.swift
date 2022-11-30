//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 27/11/22.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        image.tintColor = .gray
        return image
        
    }()
    
    private let firstNameTextField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = "First Name"
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.returnKeyType = .continue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
        
    }()
    
    private let secondNameTextField: UITextField = {
        
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = "Second Name"
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.returnKeyType = .continue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
        
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
    
    private let registerButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
        
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        dismissKeyboardWhenTappedAround()
        
        firstNameTextField.delegate = self
        firstNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameTextField)
        scrollView.addSubview(secondNameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(tap)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height)
            make.width.equalTo(view.snp.width)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.centerX.equalTo(view)
            make.width.height.equalTo(100)
        }
        
        firstNameTextField.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        secondNameTextField.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(firstNameTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(secondNameTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        registerButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
    }
    
    // MARK: - Selectors
    
    @objc private func didTapChangeProfilePic(){
        print("Change User profile image")
    }
    
    @objc private func registerButtonTapped(){
        
        self.view.endEditing(true)
        
        guard let firstName = firstNameTextField.text, let secondName = secondNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text,
              !firstName.isEmpty, !secondName.isEmpty ,!email.isEmpty, !password.isEmpty,
              password.count >= 6 else {
                  alertUserLoginError()
                  return
              }
        
        // Firebase entry point
        print("Store data in Firebase")
    }
    
    
    // MARK: - Helper Functions
    
    func alertUserLoginError(){
        
        let alert = UIAlertController(title: "Ooops", message: "Please entry all information to create an account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            secondNameTextField.becomeFirstResponder()
        } else if textField == secondNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            registerButtonTapped()
        }
        
        return true
    }
    
}
