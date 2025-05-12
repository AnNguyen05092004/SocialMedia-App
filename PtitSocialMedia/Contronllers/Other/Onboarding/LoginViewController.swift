//
//  LoginViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {
    
    struct Constants {
        static let cornerRadius: CGFloat = 8.0
    }
    
    private let usernameEmailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter your email..."
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor // border require cgcolor
        return field
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Terms of Service", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal) // màu sắc nhạt hơn màu chính
        return button
    }()
    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal) // màu sắc nhạt hơn màu chính
        return button
    }()
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("New user? Create an account", for: .normal)
        return button
    }()
    private let headerView: UIView = {
        let header = UIView()
        header.clipsToBounds = true
        
        let backgroundImageView = UIImageView(image: UIImage(named: "gradient"))
        header.addSubview(backgroundImageView)
        return header
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        addSubviews()
        view.backgroundColor = .systemBackground
        
        usernameEmailField.delegate = self
        passwordField.delegate = self
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        // assign frame
        
        headerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: view.width,
                                  height: view.height/2.5)
        configureHeaderView()
        
        usernameEmailField.frame = CGRect(x: 25,
                                          y: headerView.bottom + 20,
                                          width: view.width - 50,
                                          height: 52)
        passwordField.frame = CGRect(x: 25,
                                     y: usernameEmailField.bottom + 10,
                                     width: view.width - 50,
                                     height: 52)
        loginButton.frame = CGRect(x: 25,
                                     y: passwordField.bottom + 10,
                                     width: view.width - 50,
                                     height: 52)
        createAccountButton.frame = CGRect(x: 25,
                                     y: loginButton.bottom + 10,
                                     width: view.width - 50,
                                     height: 52)
        termsButton.frame = CGRect(x: 10, 
                                   y: view.height - view.safeAreaInsets.bottom - 100,
                                   width: view.width-20,
                                   height: 50)
        privacyButton.frame = CGRect(x: 10,
                                     y: view.height - view.safeAreaInsets.bottom - 50,
                                     width: view.width-20,
                                     height: 50)
    }
    func configureHeaderView() {
        guard headerView.subviews.count == 1 else{
            return
        }
        guard let backgroundView = headerView.subviews.first else {
            return
        }
        backgroundView.frame = headerView.bounds
        
        // Add ptit logo
        let imageView = UIImageView(image: UIImage(named: "text"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: headerView.width/6,
                                 y: view.safeAreaInsets.top,
                                 width: headerView.width/1.5,
                                 height: headerView.height - view.safeAreaInsets.top)
        headerView.addSubview(imageView)
        
    }
    
    private func addSubviews() {
        view.addSubview(usernameEmailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
        view.addSubview(createAccountButton)
        view.addSubview(headerView)
    }
    
    
    @objc private func didTapLoginButton() {
        view.endEditing(true)

        guard let usernameEmail = usernameEmailField.text, !usernameEmail.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            showAlert(title: "Missing Info", message: "Please enter your email/username and password (≥ 8 characters).")
            return
        }

        var username: String?
        var email: String?

        if usernameEmail.contains("@"), usernameEmail.contains(".") {
            email = usernameEmail
        } else {
            username = usernameEmail
        }

        AuthManager.shared.loginUser(userName: username, email: email, password: password) { success in
            DispatchQueue.main.async {
                if success {
                    self.dismiss(animated: true)
                } else {
                    self.showAlert(title: "Login Failed", message: "Please check your credentials and try again.")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    @objc private func didTapTermsButton() {
        guard let url = URL(string: "https://cds.ptit.edu.vn/terms-of-service") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    @objc private func didTapPrivacyButton() {
        guard let url = URL(string: "https://cds.ptit.edu.vn/privacy-policy") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)

    }
    @objc private func didTapCreateAccountButton(){
        let vc = RegistrationViewController()
        vc.title = "Create Your Account"
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameEmailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }
        
        return true
    }
}
