//
//  NotificationsViewController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit

private let cellIden = "NotificationCell"

class NotificationsViewController: UITableViewController {

    // MARK: - Properties
    
    private var notifications = [NotificationModel]() {
        didSet {
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()
        self.fetNotification()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Api
    
    private func fetNotification() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotification(completion: { [weak self]  in
            guard let `self` = self else { return }
            self.notifications = $0.sorted {
                $0.timestamp > $1.timestamp
            }
            self.checkIfUserIsFollowed(notifications: $0)
        })
    }
    
    private func checkIfUserIsFollowed(notifications: [NotificationModel]) {
        
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in
            guard case .follow = notification.type else { return }
            
            let user = notification.user
            UserService.shared.checkFollowUser(uid: user.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self.notifications[index].user.isFollowed = true
                }
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        self.fetNotification()
    }
    
    // MARK: - Helpers
    private func configureViewController() {
        self.navigationItem.title = "Notifications"
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "NotificationTBVCell", bundle: nil), forCellReuseIdentifier: cellIden)

        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.primary.cgColor, UIColor.secondary.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)

            if let image = UIImage.getImageFrom(gradientLayer: gradient) {
                let app = UINavigationBarAppearance()
                app.backgroundImage = image
                self.navigationController?.navigationBar.scrollEdgeAppearance = app
                self.navigationController?.navigationBar.standardAppearance = app

            }
            navigationBar.applyNavBarCornerRadius(radius: 12)
        }
    }

}

// MARK: - UITableViewDelegate

extension NotificationsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notifications[indexPath.row]
        guard let tweetId = notification.tweetId else { return }
        TweetService1.shared.fetchTweet(withTweetId: tweetId) { tweet in
            let tweetController = TweetController(tweet)
            self.navigationController?.pushViewController(tweetController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension NotificationsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIden, for: indexPath) as? NotificationTBVCell else {
            return NotificationTBVCell()
        }
        cell.notification = self.notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 + 24
    }
}

// MARK: - NotificationCellDelegate


extension NotificationsViewController: NotificationCellDelegate {
    
    func didTapProfileImage(_ cell: NotificationTBVCell) {
        guard let user = cell.notification?.user else { return }
        let profileController = ProfileController(user)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    func didTapFollow(_ cell: NotificationTBVCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { err, ref in
                cell.notification?.user.isFollowed = true
            }
        }
    }

}
