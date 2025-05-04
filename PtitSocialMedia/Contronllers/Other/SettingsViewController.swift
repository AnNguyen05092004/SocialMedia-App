//
//  SettingsViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import SafariServices

struct SettingCellModel {
    let title: String
    let handler: (() -> Void) // Một closure, khi người dùng bấm vào dòng đó thì chạy đoạn code bên trong.
}

class SettingsViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        configureModels()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds // căng toàn màn hình
    }

    private var data =  [[SettingCellModel]]()
    private func configureModels() {
        data.append([
            SettingCellModel(title: "EditProfile") { [weak self] in //    Tránh retain cycle
                self?.didTapEditProfile()
            },
            SettingCellModel(title: "Invite Friends") { [weak self] in //    Tránh retain cycle
                self?.didTapInviteFriends()
            },
            SettingCellModel(title: "Save Original Posts") { [weak self] in
                self?.didTapSaveOriginalPosts()
            }
        ])
        
        data.append([
            SettingCellModel(title: "Term of Service") { [weak self] in
                self?.openURL(type: .terms)
            },
            SettingCellModel(title: "Privacy Policy") { [weak self] in // Tránh giữ SettingCellModel hoặc giữ data
                self?.openURL(type: .privacy)
            },
            SettingCellModel(title: "Help") { [weak self] in
                self?.openURL(type: .help)
            }
        ])

        data.append([
            SettingCellModel(title: "Log Out") { [weak self] in
                self?.didTapLogOut()
            }
        ])
    }
    
    private func didTapEditProfile() {
        let vc = EditProfileViewController()
        vc.title = "Edit Profile"
        let naVC = UINavigationController(rootViewController: vc)
        naVC.modalPresentationStyle = .fullScreen
        present(naVC, animated: true)
    }
    
    private func didTapInviteFriends() {
        // show share sheet to invite friends
        
    }
    
    private func didTapSaveOriginalPosts() {
        
    }
    
    enum SettingsURLType {
        case terms, privacy, help
    }
    private func openURL(type: SettingsURLType) {
        let urlString: String
        switch type {
            case .terms: urlString = "https://cds.ptit.edu.vn/terms-of-service"
            case.privacy: urlString = "https://cds.ptit.edu.vn/privacy-policy"
            case.help: urlString = "https://ptit.edu.vn/"
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    private func didTapLogOut() {
        let actionSheet = UIAlertController(title: "Log Out",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            AuthManager.shared.logOut { success in
                DispatchQueue.main.async {
                    if success {
                        // present Login
                        let loginVC = LoginViewController()
                        loginVC.modalPresentationStyle = .fullScreen
                        self.present(loginVC, animated: true)
                        self.navigationController?.popToRootViewController(animated: false)
                        self.tabBarController?.selectedIndex = 0 //TabBarController, chuyển về tab đầu tiên
                    } else {
                        fatalError("Could not log out")
                    }
                }
            }
        }))
        // 2 dòng để tránh lỗi trên ipad
        actionSheet.popoverPresentationController?.sourceView = tableView
        actionSheet.popoverPresentationController?.sourceRect = tableView.bounds
        
        present(actionSheet, animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section][indexPath.row].handler()
    }
    
}
