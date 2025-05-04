//
//  ViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 27/03/2025.
//

import UIKit
import Firebase

struct HomeFeedRenderViewModel {
    let header: PostRenderViewModel
    let post: PostRenderViewModel
    let actions: PostRenderViewModel
    let comments: PostRenderViewModel
}

class HomeViewController: UIViewController {
    
    private var feedRenderModels = [HomeFeedRenderViewModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        // register cell
        tableView.register(FeedPostTableViewCell.self, forCellReuseIdentifier: FeedPostTableViewCell.identifier)
        tableView.register(FeedPostHeaderTableViewCell.self, forCellReuseIdentifier: FeedPostHeaderTableViewCell.identifier)
        tableView.register(FeedPostActionsTableViewCell.self, forCellReuseIdentifier: FeedPostActionsTableViewCell.identifier)
        tableView.register(FeedPostGeneralTableViewCell.self, forCellReuseIdentifier: FeedPostGeneralTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        handleNoAuthenticated()
        
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print ("Failed to sign out")
//        }
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        createMockModels()
    }
    
    private func createMockModels() {
        let user = User(username: "@an",
                        bio: "Ptit student",
                        name: (first: "Nguyen", last: "An"),
                        profilePhoto: URL(string: "https://www.google.com/")!,
                        birthDate: Date(),
                        gender: .male,
                        counts: UserCount(followers: 1, following: 2, posts: 2),
                        joinDate: Date())
        let post = UserPost(identifier: "",
                            postType: .photo,
                            thumbnailImage: URL(string: "https://www.google.com/")!,
                            postURL: URL(string: "https://www.google.com/")!,
                            caption: "This post is hardcode",
                            likeCount: [],
                            comments: [],
                            createdData: Date(),
                            taggedUsers: [],
                            owner: user)
        var comments = [PostComment]()
        for x in 0..<4 {
            comments.append(PostComment(identifier: "\(x)", username: "@Binh", text: "This is the besst Post", createdDate: Date(), like: []))
        }
        
        for x in 0..<5 {
            let viewModel = HomeFeedRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: user)),
                                                    post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                                                    actions: PostRenderViewModel(renderType: .action(provider: "")),
                                                    comments: PostRenderViewModel(renderType: .comments(comments: comments)))
            feedRenderModels.append(viewModel)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func handleNoAuthenticated() {
        // check the status
        if Auth.auth().currentUser == nil {
            // show login
            let loginVc = LoginViewController()
            loginVc.modalPresentationStyle = .fullScreen
            present(loginVc, animated: true)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRenderModels.count * 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = section
        let model: HomeFeedRenderViewModel
//        if x == 0 {
//            model = feedRenderModels[0]
//        } else {
//            let position = x % 4 == 0 ? x/4 : ((x-(x % 4)) / 4)
//            model = feedRenderModels[position]
//        }
        let position = x/4
        model = feedRenderModels[position]
        
        let subSection = x % 4
        if subSection == 0 {
            // header
            return 1
        } else if subSection == 1 {
            // post
            return 1
        } else if subSection == 2 {
            // actions
            return 1
        } else if subSection == 3 {
            // comments
            let commentsModel = model.comments
            switch commentsModel.renderType {
                case .comments(let comments):
                    return comments.count > 2 ? 2 : comments.count
                case .header, .action, .primaryContent: return 0
            }
        }
        
//        switch renderModels[section].renderType {
//            case.action(_): return 1
//            case.comments(let commments): return commments.count>4 ? 4 : commments.count
//            case.primaryContent(_): return 1
//            case.header(_): return 1
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let x = indexPath.section
        let model: HomeFeedRenderViewModel
        //        if x == 0 {
        //            model = feedRenderModels[0]
        //        } else {
        //            let position = x % 4 == 0 ? x/4 : ((x-(x % 4)) / 4)
        //            model = feedRenderModels[position]
        //        }
        let position = x/4
        model = feedRenderModels[position]
        
        let subSection = x % 4
        if subSection == 0 {
            // header
            let headerModel = model.header
            switch headerModel.renderType {
                case.header(let user):
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostHeaderTableViewCell.identifier, for: indexPath) as! FeedPostHeaderTableViewCell
                    cell.configure(with: user)
                    cell.delegate = self
                    return cell
                case .comments, .action, .primaryContent: return UITableViewCell()
            }
        } else if subSection == 1 {
            // post
            let postModel = model.post
            switch postModel.renderType {
                case.primaryContent(let post):
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostTableViewCell.identifier, for: indexPath) as! FeedPostTableViewCell
                    cell.configure(with: post)
                    return cell
                case .comments, .action, .header: return UITableViewCell()
            }
        } else if subSection == 2 {
            // actions
            let actionsModel = model.actions
            switch actionsModel.renderType {
                case.action(let actions):
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostActionsTableViewCell.identifier, for: indexPath) as! FeedPostActionsTableViewCell
                    cell.delegate = self
                    return cell
                case .comments, .primaryContent, .header: return UITableViewCell()
            }
        } else if subSection == 3 {
            // comments
            let commentModel = model.comments
            switch commentModel.renderType {
                case .comments(let comments):
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostGeneralTableViewCell.identifier, for: indexPath) as! FeedPostGeneralTableViewCell
                    return cell
                case .primaryContent, .action, .header: return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subSection = indexPath.section % 4
        if subSection == 0 {
            return 70
        } else if subSection == 1 {
            return tableView.width
        } else if subSection == 2 {
            return 60
        } else if subSection == 3 {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let subSection = section % 4
        return subSection == 3 ? 70 : 0
    }
}

extension HomeViewController: FeedPostHeaderTableViewCellDelegate {
    func didTapMoreButton() {
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in
            self?.reportPost()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    func reportPost() {
        
    }
}

extension HomeViewController: FeedPostActionsTableViewCellDelegate {
    func didTapLikeButton() {
        print("like")
    }
    
    func didTapComnentButton() {
        print("comment")
    }
    
    func didTapSendButton() {
        print("send")
    }
    
    
}
