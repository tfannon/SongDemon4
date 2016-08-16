//
//  MessagesViewController.swift
//  SongDemonChat
//
//  Created by Tommy Fannon on 8/12/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController:
    MSMessagesAppViewController, UITableViewDelegate, UITableViewDataSource, VideoControllerDelegate {
    
    // MARK: - Constants
    let VideoCellIdentifier : String = "VideoCell"
    let VideoControllerIdentifier : String = "VideoController"
    let MessageURLNamePrefix = "Video"

    // MARK: - Fields
    let testVideos =
        [
            Video(id: "_jIzC1ChqDU", artist: "AR Studios", title: "Daughters"),
            Video(id: "frdj1zb9sMY", artist: "Disney",  title: "Rogue Squadron"),
            Video(id: "_OBlgSz8sSM", artist: "Charlie",  title: "Charlie Bit Me!"),
            Video(id: "BIPCn-aYMoM", artist: "Cameron",  title: "Terminator Gun Scene"),
            Video(id: "A_-KXsee5vA", artist: "Arthur",  title: "Moose"),
            Video(id: "9V7zbWNznbs", artist: "Monty Python",  title: "French Taunting")
        ]
    var videos : [Video] = []
    
    // MARK: - Outlets & Actions
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    
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

        if (Utils.inSimulator)
        {
            VideoLibrary.removeAll()
            testVideos.forEach { x in VideoLibrary.add(video: x) }
        }
        
        // rounded edge
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8;
        
        // tableview
        tableView.delegate = self
        tableView.dataSource = self
        refreshTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func refreshTable() {
        videos = VideoLibrary.getAll()
        tableView.reloadData()
    }
    
    func shareVideo(video: Video) {
        // return the extension to compact mode
        requestPresentationStyle(.compact)
        
        // do a quick sanity check to make sure we have a conversation to work with
        guard let conversation = activeConversation else { return }
        
        // convert our information into URLQueryItem objects
        var components = URLComponents()
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: MessageURLNamePrefix, value: video.toJson()))
        components.queryItems = items
        
        // use the existing session or create a new one
        let session = conversation.selectedMessage?.session ?? MSSession()
        
        // create a new message from the session and assign it the URL we created from our dates and votes
        let message = MSMessage(session: session)
        message.url = components.url
        
        // create a blank, default message layout
        let layout = MSMessageTemplateLayout()
        layout.caption = "Check out this video!"
        message.layout = layout
        
        // insert it into the conversation
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func showShareableList() {
        removeViewControllers()
        refreshTable()
    }
    
    // MARK: - Events

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCellIdentifier, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Configure the cell...
        let video = videos[indexPath.row]
        cell.textLabel?.text = video.artist
        cell.detailTextLabel?.text = video.title
        if let url = URL(string: video.artworkUrl) {
            url.getImage { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                    }
                }
                else if let error = error {
                    print (error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        shareVideo(video: video)
    }
    
    // MARK: - UI
    func removeViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    func showViewController(identifier: String) -> UIViewController? {
        
        // create the child view controller
        guard let vc =
            storyboard?.instantiateViewController(withIdentifier: identifier) else { return nil }
        
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
    
    // MARK: - VideoControllerDelegate
    func videoSelected() {
        requestPresentationStyle(.compact)
    }
    
    // MARK: - Conversation Handling
    
    private func showSharedVideo(message : MSMessage) -> Bool {
        guard let messageURL = message.url else { return false }
        guard let urlComponents = NSURLComponents(url: messageURL,
                                                  resolvingAgainstBaseURL: false) else { return false }
        guard let queryItems = urlComponents.queryItems else { return false }
        guard let queryItem = queryItems.first(where: { x in x.name.hasPrefix(MessageURLNamePrefix) }) else { return false }
        guard let video = Video.fromJson(jsonString: queryItem.value!) else { return false }

        let vc = showViewController(identifier: VideoControllerIdentifier) as! VideoController
        vc.delegate = self
        vc.video = video
        
        return true
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        let _ = showSharedVideo(message: message)
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        guard let message = conversation.selectedMessage else { return }
        let _ = showSharedVideo(message: message)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
        removeViewControllers()
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
        if presentationStyle == .compact {
            showShareableList()
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
