import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrationViewController: UIViewController {

    struct Constants {
        static let cornerRadius: CGFloat = 8.0
    }

    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.configureAsInput()
        return field
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.keyboardType = .emailAddress
        field.configureAsInput()
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password (≥ 8 characters)"
        field.isSecureTextEntry = true
        field.configureAsInput()
        return field
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        [usernameField, emailField, passwordField, registerButton].forEach {
            view.addSubview($0)
        }

        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        [usernameField, emailField, passwordField].forEach { $0.delegate = self }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fieldHeight: CGFloat = 52
        let spacing: CGFloat = 10

        usernameField.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 100, width: view.width - 40, height: fieldHeight)
        emailField.frame = CGRect(x: 20, y: usernameField.bottom + spacing, width: view.width - 40, height: fieldHeight)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom + spacing, width: view.width - 40, height: fieldHeight)
        registerButton.frame = CGRect(x: 20, y: passwordField.bottom + spacing, width: view.width - 40, height: fieldHeight)
    }

    @objc private func didTapRegister() {
        view.endEditing(true)

        guard let email = emailField.text, !email.isEmpty,
              let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            showAlert(title: "Error", message: "Please enter all fields correctly.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }

            if let error = error {
                strongSelf.showAlert(title: "Registration Failed", message: error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else {
                strongSelf.showAlert(title: "Error", message: "Unexpected error occurred.")
                return
            }

            let userData: [String: Any] = [
                "user_id": uid,
                "username": username,
                "email": email,
                "bio": "",
                "first_name": "",
                "last_name": "",
                "profile_photo_url": "",
                "birth_date": Timestamp(date: Date()),
                "gender": "other",
                "followers": 0,
                "following": 0,
                "posts": 0,
                "join_date": Timestamp(date: Date())
            ]

            Firestore.firestore().collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    strongSelf.showAlert(title: "Database Error", message: error.localizedDescription)
                } else {
                    strongSelf.showAlert(title: "Success", message: "Registration successful!") {
                        strongSelf.dismiss(animated: true)
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

extension UITextField {
    func configureAsInput() {
        returnKeyType = .next
        leftViewMode = .always
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        autocapitalizationType = .none
        autocorrectionType = .no
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.masksToBounds = true
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            didTapRegister()
        }
        return true
    }
}
