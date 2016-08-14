//
//  MessagesViewController.swift
//  SongDemonChat
//
//  Created by Tommy Fannon on 8/12/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Fields
    let VideoViewControllerIdentifier : String = "VideoViewController"
    let testVideos =
        [
            Video(artist: "AR Studios", title: "Daughters", url: "https://www.youtube.com/watch?v=_jIzC1ChqDU"),
            Video(artist: "Disney", title: "Rogue Squadron", url: "https://www.youtube.com/watch?v=frdj1zb9sMY"),
            Video(artist: "Charlie", title: "Charlie Bit Me!", url: "https://www.youtube.com/watch?v=_OBlgSz8sSM"),
            Video(artist: "Cameron", title: "Terminator Gun Scene", url: "https://www.youtube.com/watch?v=BIPCn-aYMoM"),
            Video(artist: "Arthur", title: "Moose", url: "https://www.youtube.com/watch?v=A_-KXsee5vA"),
            Video(artist: "Monty Python", title: "French Taunting", url: "https://www.youtube.com/watch?v=9V7zbWNznbs")
        ]
    
    // MARK: - Outlets & Actions
    @IBAction func shareVideos(_ sender: UIButton) {
        onShareVideos()
    }
    @IBAction func doMisc(_ sender: UIButton) {
        onMisc()
    }
    
    // MARK: - UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = Utils.AppGroupDefaults
        if let foo = defaults.object(forKey: "SongDemonMain") as? String {
            print (foo)
        }
        
        //defaults.set("Hello from Chat", forKey: "SongDemonChat")
        if let bar = defaults.object(forKey: "SongDemonChat") as? String {
            print (bar)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Events
    
    private func onShareVideos() {
        // return the extension to compact mode
        requestPresentationStyle(.compact)
        
        // do a quick sanity check to make sure we have a conversation to work with
        guard let conversation = activeConversation else { return }
        
        // populate a collection of URLs (test)
        let videos = testVideos
        
        // convert our information into URLQueryItem objects
        var components = URLComponents()
        var items = [URLQueryItem]()
        for (index, video) in videos.enumerated() {
            items.append(URLQueryItem(name: "title-\(index)", value: video.title))
            items.append(URLQueryItem(name: "url-\(index)", value: video.url))
            items.append(URLQueryItem(name: "artist-\(index)", value: video.artist))
        }
        components.queryItems = items

        // use the existing session or create a new one
        let session = conversation.selectedMessage?.session ?? MSSession()
        
        // create a new message from the session and assign it the URL we created from our dates and votes
        let message = MSMessage(session: session)
        message.url = components.url
        
        // create a blank, default message layout
        let layout = MSMessageTemplateLayout()
        layout.caption = "Check out these videos!"
        message.layout = layout
        
        // insert it into the conversation
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func onMisc() {
        requestPresentationStyle(.expanded)
        let vc = showViewController(identifier: VideoViewControllerIdentifier) as! VideoViewController
        vc.demonVideos = testVideos
    }
    
    func onOpenMessage(conversation: MSConversation) {
        
    }
    
    // MARK: - UI
    func showViewController(identifier: String) -> UIViewController? {
        
        // create the child view controller
        guard let vc =
            storyboard?.instantiateViewController(withIdentifier: identifier) as?
            VideoViewController else { return nil }
        
        // add the child to the parent so that events are forwarded
        addChildViewController(vc)
        
        // give the child a meaningful frame: make it fill our view
        vc.view.frame = view.bounds
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        
        // add Auto Layout constraints so the child view fills the full view
        vc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        
        // tell the child it has now moved to a new parent view controller
        vc.didMove(toParentViewController: self)
        
        // return it
        return vc
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.

        guard let message = conversation.selectedMessage else { return }
        guard let messageURL = message.url else { return }
        guard let urlComponents = NSURLComponents(url: messageURL,
                                                  resolvingAgainstBaseURL: false) else { return }
        guard let queryItems = urlComponents.queryItems else { return }

        var videos : [Video] = []
        for i in stride(from: 0, through: queryItems.count - 1, by: 3) {
            let index = i / 3
            var title : String = ""
            var url : String = ""
            var artist : String = ""
            
            for j in 0..<3 {
                let queryItem = queryItems[i + j]
                if queryItem.name == "title-\(index)" {
                    title = queryItem.value ?? ""
                }
                else if queryItem.name == "artist-\(index)" {
                    artist = queryItem.value ?? ""
                }
                else if queryItem.name == "url-\(index)" {
                    url = queryItem.value ?? ""
                }
            }
            
            let video = Video(artist: artist, title: title, url: url)
            videos.append(video)
        }
        
        if let vc = showViewController(identifier: VideoViewControllerIdentifier) {               (vc as! VideoViewController).demonVideos = videos
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
