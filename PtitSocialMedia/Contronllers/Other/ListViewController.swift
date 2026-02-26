//
//  ListViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import FirebaseAuth

class ListViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserFollowTableViewCell.self, forCellReuseIdentifier: UserFollowTableViewCell.identifier)
        
        return tableView
    }()
    
    private var data: [UserRelationship]
    init(data: [UserRelationship]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserFollowTableViewCell.identifier, for: indexPath) as! UserFollowTableViewCell
        cell.configure(with: data[indexPath.row])
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = data[indexPath.row]
        
        guard let currentUID = Auth.auth().currentUser?.uid, model.userId != currentUID else {
            return
        }
        
        let vc = OtherUserProfileViewController(userId: model.userId)
        vc.title = model.username
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension ListViewController: UserFollowTableViewCellDelete {
    func didTapFollowUnfollowButton(model: UserRelationship) {
        guard let index = data.firstIndex(where: { $0.userId == model.userId }) else { return }
        
        switch model.type {
            case .following:
                DatabaseManager.shared.unfollowUser(targetUID: model.userId) { [weak self] success in
                    guard success else { return }
                    self?.data[index].type = .notFollowing
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            case .notFollowing:
                DatabaseManager.shared.followUser(targetUID: model.userId) { [weak self] success in
                    guard success else { return }
                    self?.data[index].type = .following
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
        }
    }
}
