//
//  Tweet.swift
//  Project
//
//  Created by Be More on 10/14/20.
//

import Foundation

class Tweet {
    let caption: String
    let tweetId: String
    var likes = Observable<Int>()
    var comments = Observable<Int>()
    var timestamp: Date!
    let retweets: Int
    var user: User!
    var didLike = Observable<Bool>()
    var replyingTo: String?
    
    var isReply: Bool {
        return self.replyingTo != nil
    }
    
    init(user: User, tweetId: String, dictionary: [String: Any]) {
        
        self.didLike.value = false
        
        self.tweetId = tweetId
        self.user = user
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes.value = dictionary["likes"] as? Int ?? 0
        self.comments.value = dictionary["comments"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
    }
    
}
