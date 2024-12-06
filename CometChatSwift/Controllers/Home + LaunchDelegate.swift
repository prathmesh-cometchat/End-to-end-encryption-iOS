//
//  Home + LaunchDelegate.swift
//  CometChatSwift
//
//  Created by admin on 12/10/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import Foundation
import CometChatSDK
import CometChatUIKitSwift
import CometChatCallsSDK
import UIKit

extension Home : LaunchDelegate {
    
    func saveDataToLocalFile(data: Data, fileName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("File successfully saved at: \(fileURL)")
            return fileURL
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteLocalFile(fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("File deleted successfully.")
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
    }
    
    func readDataFromFile(fileURL: URL) -> Data? {
        do {
            let data = try Data(contentsOf: fileURL)
            print("Data read successfully from: \(fileURL)")
            return data
        } catch {
            print("Failed to read data from file: \(error.localizedDescription)")
            return nil
        }
    }

    func getLocalFilePath(fileName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            print("File not found at: \(fileURL)")
            return nil
        }
    }

    
    func launchConversationsWithMessages() {

        // MARK : Encryption Code
        
        let messageComposerConfiguration = MessageComposerConfiguration()
                    .setOnSendButtonClick { basemessage in
                        //For encryption
                        if let message = basemessage as? TextMessage {
                            EncryptionManager.shared.encryptMessage(receiverId: message.receiverUid, messageToEncrypt: message.text) { encryptedMessage in
                                if let encMessage = encryptedMessage {
                                    let textMessage = TextMessage(receiverUid: message.receiverUid, text: encMessage as! String, receiverType: .user)
                                    CometChatUIKit.sendTextMessage(message: textMessage)
                                }
                            }
                        }
//                        else
//                        if let mediaMessage = basemessage as? TextMessage {
//                            let text = "random"
//                            EncryptionManager.shared.encryptMedia(receiverId: mediaMessage.receiverUid, message: mediaMessage.text) { encryptedData in
//                                if let encryptedData = encryptedData as? Data {
//                                    print("enc data\(encryptedData)")
//                                    if let fileURL = self.saveDataToLocalFile(data: encryptedData, fileName: "encryptedImage.jpeg") {
//                                        let mediaMessage = MediaMessage(receiverUid: mediaMessage.receiverUid, fileurl: fileURL.absoluteString, messageType: .image, receiverType: .user)
//                                        CometChatUIKit.sendMediaMessage(message: mediaMessage)
//                                    }
//                                }
//                            }
//                        }
                        //For decryption
//                        if let message = basemessage as? TextMessage {
//                            EncryptionManager.shared.decryptMessage(encryptedMessage: message.text, senderId: message.receiverUid) { decryptedMessage in
//                                if let decMessage = decryptedMessage {
//                                    let textMessage = TextMessage(receiverUid: message.receiverUid, text: decMessage , receiverType: .user)
//                                    CometChatUIKit.sendTextMessage(message: textMessage)
//                                }
//                            }
//                        }
//                        else {
//                            if let mediaMessage = basemessage as? TextMessage {
//                                let text = "encryptedImage.jpeg"
//                                let fileURL = self.getLocalFilePath(fileName: text)
//                                if let fileURL = fileURL {
//                                    let encryptedData = self.readDataFromFile(fileURL: fileURL)
//                                    EncryptionManager.shared.decryptMedia(encryptedData: encryptedData, senderId: mediaMessage.receiverUid) { originalData in
//                                        if let originalData = originalData {
//                                            let dataFileUrl = self.saveDataToLocalFile(data: originalData, fileName: "decryptedImage.jpeg")
//                                            let mediaMessage = MediaMessage(receiverUid: mediaMessage.receiverUid, fileurl: dataFileUrl?.absoluteString, messageType: .image, receiverType: .user)
//                                            CometChatUIKit.sendMediaMessage(message: mediaMessage)
//
//                                        }
//                                    }
//                                }
//                        }
                    }
                
                let messagesConfiguration = MessagesConfiguration()
                    .set(messageComposerConfiguration: messageComposerConfiguration)
                
                let conversationsWithMessages = CometChatConversationsWithMessages()
                    .set(messagesConfiguration: messagesConfiguration)
                presentViewController(viewController: conversationsWithMessages, isNavigationController: true)
    }
    func printingMessage(textMessage: TextMessage){
        CometChatUIKit.sendTextMessage(message: textMessage)
        

    }
    
    func launchConversations() {
        let conversations = CometChatConversations()
        presentViewController(viewController: conversations, isNavigationController: true)
        
    }
    
    func launchListItemForConversation() {
        let listItem = ListItem()
        listItem.listItemTypes = [.conversation]
        self.presentViewController(viewController: listItem, isNavigationController: false)
    }
    
    func launchContacts() {
        let usersConfiguration = UsersConfiguration()
            .hide(separator: true)
        
        let contact = CometChatContacts()
            .setUsersConfiguration(usersConfiguration: usersConfiguration)
        
        let naviVC = UINavigationController(rootViewController: contact)
        presentViewController(viewController: naviVC, isNavigationController: false)
    }
    
    ///Calls
    func launchCallButtonComponent() {
        let callButtons = CallButtonsComponent()
        presentViewController(viewController: callButtons, isNavigationController: false)
    }
    
    func launchCallLogsComponent() {
        #if canImport(CometChatCallsSDK)
        let callLogs = CometChatCallLogs()
        presentViewController(viewController: callLogs, isNavigationController: true)
        #else
        self.showAlert(title: "Calls SDK is Installed", msg: "Calls SDK is required to access this class")
        #endif
    }
    
    func launchCallLogsWithDetailsComponent() {
        #if canImport(CometChatCallsSDK)
        let callLogsWithDetails = CometChatCallLogsWithDetails()
        presentViewController(viewController: callLogsWithDetails, isNavigationController: true)
        #else
        self.showAlert(title: "Calls SDK is Installed", msg: "Calls SDK is required to access this class")
        #endif
    }
    
    func launchCallLogDetailsComponent() {
        #if canImport(CometChatCallsSDK)
        let callLog = DummyObject.callLog(user: CometChat.getLoggedInUser())
        let callLogDetails = CometChatCallLogDetails()
        callLogDetails.set(callLog: callLog)
        presentViewController(viewController: callLogDetails, isNavigationController: true)
        #else
        self.showAlert(title: "Calls SDK is Installed", msg: "Calls SDK is required to access this class")
        #endif
    }
    
    func launchCallLogParticipantComponent() {
        #if canImport(CometChatCallsSDK)
        let callLogParticipant = CometChatCallLogParticipant()
            .set(callLog: DummyObject.callLog(user: CometChat.getLoggedInUser()))
        presentViewController(viewController: callLogParticipant, isNavigationController: true)
        #else
        self.showAlert(title: "Calls SDK is Installed", msg: "Calls SDK is required to access this class")
        #endif
    }
    
    func launchCallLogRecordingComponent() {
        #if canImport(CometChatCallsSDK)
        let callLogRecording = CometChatCallLogRecording()
            .set(recordings: DummyObject.callLog(user: CometChat.getLoggedInUser()).recordings)
        presentViewController(viewController: callLogRecording, isNavigationController: true)
        #else
        self.showAlert(title: "Calls SDK is Installed", msg: "Calls SDK is required to access this class")
        #endif
    }
    
    func launchCallLogHistoryComponent() {
        #if canImport(CometChatCallsSDK)
        let callLogHistory = CometChatCallLogHistory()
            .set(uid: CometChat.getLoggedInUser()?.uid != "superhero1" ? "superhero1" : "superhero2")
        presentViewController(viewController: callLogHistory, isNavigationController: true)
        #else
        self.showAlert(title: "Calls SDK is Installed", msg: "Calls SDK is required to access this class")
        #endif
    }
    
    ///Users
    func launchUsersWithMessages() {
        let usersWithMessages = CometChatUsersWithMessages()
        presentViewController(viewController: usersWithMessages, isNavigationController: true)
    }
    
    func launchUsers() {
        let users = CometChatUsers()
        presentViewController(viewController: users, isNavigationController: true)
    }

    func launchListItemForUser() {
        let listItem = ListItem()
        listItem.listItemTypes = [.user]
        self.presentViewController(viewController: listItem, isNavigationController: false)
    }
    
    func launchDetailsForUser() {
        CometChat.getUser(UID: "superhero1", onSuccess: { user in
            DispatchQueue.main.async {
                let detailsForUser = CometChatDetails()
                detailsForUser.set(user: user)
                self.presentViewController(viewController: detailsForUser, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    ///Groups
    func launchGroupsWithMessages() {
        
        let groupsWithMessages = CometChatGroupsWithMessages()
        presentViewController(viewController: groupsWithMessages, isNavigationController: true)

    }
    
    func launchGroups() {
        let groups = CometChatGroups()
        presentViewController(viewController: groups, isNavigationController: true)
    }
    
    func launchListItemForGroup() {
        let listItem = ListItem()
        listItem.listItemTypes = [.group]
        self.presentViewController(viewController: listItem, isNavigationController: false)
    }
    
    func launchCreateGroup() {
        let createGroup = CometChatCreateGroup()
        self.presentViewController(viewController: createGroup, isNavigationController: true)
    }
    
    func launchJoinPasswordProtectedGroup() {
        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                let joinProtectedGroup = CometChatJoinProtectedGroup()
                joinProtectedGroup.set(group: group)
                self.presentViewController(viewController: joinProtectedGroup, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    func launchViewMembers() {
        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                let groupMembers = CometChatGroupMembers(group: group)
                self.presentViewController(viewController: groupMembers, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    func launchAddMembers() {
        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                let addMembers = CometChatAddMembers(group: group)
                self.presentViewController(viewController: addMembers, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    func launchBannedMembers() {
        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                
                let bannedMembers =  CometChatBannedMembers(group: group)
                self.presentViewController(viewController: bannedMembers, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    func launchTransferOwnership() {

        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                let transferOwnerShip = CometChatTransferOwnership(group: group)
                self.presentViewController(viewController: transferOwnerShip, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    func launchDetailsForGroup() {
        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                let detailsForGroup = CometChatDetails()
                detailsForGroup.set(group: group)
                self.presentViewController(viewController: detailsForGroup, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    ///Messages
    func launchMessages() {
        CometChat.getGroup(GUID: "supergroup", onSuccess: { group in
            DispatchQueue.main.async {
                let messages = CometChatMessages()
                messages.set(group: group)
                self.presentViewController(viewController: messages, isNavigationController: true)
            }
        }, onError: { error in
            self.showAlert(title: "Error", msg: error?.errorDescription ?? "")
        })
    }
    
    func launchMessageHeader() {
        let messageHeader = MessageHeaderComponent()
        presentViewController(viewController: messageHeader, isNavigationController: false)
    }
    
    func launchMessageList() {
        let messageList = MessageListComponent()
        presentViewController(viewController: messageList, isNavigationController: false)
    }
    
    func launchMessageComposer() {
        let messageComposer = MesaageComposerComponent()
        presentViewController(viewController: messageComposer, isNavigationController: false)
    }
    
    func launchMessageInformation() {
        var types = [String]()
        var categories = [String]()
        var templates = [(type: String, template: CometChatMessageTemplate)]()
        let messageTypes =  CometChatUIKit.getDataSource().getAllMessageTemplates()
        for template in messageTypes {
            if !(categories.contains(template.category)){
                categories.append(template.category)
            }
            if !(types.contains(template.type)){
                types.append(template.type)
            }
            templates.append((type: template.type, template: template))
        }
        
        let messageInformationController = CometChatMessageInformation()
        let navigationController = UINavigationController(rootViewController: messageInformationController)
        
        let message = TextMessage(receiverUid: CometChatUIKit.getLoggedInUser()?.uid ?? "", text: "Hi", receiverType: .user)
        message.readAt = Date().timeIntervalSince1970
        message.deliveredAt = Date().timeIntervalSince1970
        message.sender = CometChatUIKit.getLoggedInUser()
        message.receiver = CometChatUIKit.getLoggedInUser()
        messageInformationController.set(message: message)
        
        if let template = templates.filter({$0.template.type == MessageUtils.getDefaultMessageTypes(message: message) && $0.template.category == MessageUtils.getDefaultMessageCategories(message: message) }).first?.template {
            messageInformationController.set(template: template)
        }
        
        presentViewController(viewController: navigationController, isNavigationController: false)
    }
    
    ///Shared
    func launchSoundManagerComponent() {
        
        let soundManager = SoundManagerComponent()
        self.presentViewController(viewController: soundManager, isNavigationController: false)
    }
    
    func launchThemeComponent() {
        let theme = ThemeComponent()
        self.presentViewController(viewController: theme, isNavigationController: false)
    }
    
    func launchLocalizeComponent() {
        let localize = LocalisationComponent()
        self.presentViewController(viewController: localize, isNavigationController: false)
    }
    
    func launchListItem() {
        let listItem = ListItem()
        listItem.listItemTypes = [.user,.group,.conversation]
        self.presentViewController(viewController: listItem, isNavigationController: false)
    }
    
    func launchAvatarComponent() {
        let avatarModification = AvatarModification()
        self.presentViewController(viewController: avatarModification, isNavigationController: false)
    }
    
    func launchBadgeCountComponent() {
        let badgeCountViewController = BadgeCountModification()
        self.presentViewController(viewController: badgeCountViewController, isNavigationController: false)
    }
    
    func launchStatusIndicatorComponent() {
        let statusIndicatorModification = StatusIndicatorModification()
        self.presentViewController(viewController: statusIndicatorModification, isNavigationController: false)
    }
    
    func launchMessageReceiptComponent() {
        let messageReceipt = MessageReceiptModification()
        self.presentViewController(viewController: messageReceipt, isNavigationController: false)
    }
        
    func launchTextBubbleComponent() {
        let textBubble = BubblesComponent()
        textBubble.bubbleType = .textBubble
        presentViewController(viewController: textBubble, isNavigationController: false)
    }
    
    func launchImageBubbleComponent() {
        let imageBubble = BubblesComponent()
        imageBubble.bubbleType = .imageBubble
        presentViewController(viewController: imageBubble, isNavigationController: false)
    }
    
    func launchVideoBubbleComponent() {
        let videoBubble = BubblesComponent()
        videoBubble.bubbleType = .videoBubble
        presentViewController(viewController: videoBubble, isNavigationController: false)
    }
    
    func launchAudioBubbleComponent() {
        let audioBubble = BubblesComponent()
        audioBubble.bubbleType = .audioBubble
        presentViewController(viewController: audioBubble, isNavigationController: false)
    }
    
    func launchFileBubbleComponent() {
        let fileBubble = BubblesComponent()
        fileBubble.bubbleType = .fileBubble
        presentViewController(viewController: fileBubble, isNavigationController: false)
    }
    
    func launchFormBubbleComponent() {
        let formBubble = BubblesComponent()
        formBubble.bubbleType = .formBubble
        presentViewController(viewController: formBubble, isNavigationController: false)
    }
    
    func launchCardBubbleComponent() {
        let cardBubble = BubblesComponent()
        cardBubble.bubbleType = .cardBubble
        presentViewController(viewController: cardBubble, isNavigationController: false)
    }
    
    func launchSchedulerComponent() {
        let schedulerBubble = BubblesComponent()
        schedulerBubble.bubbleType = .schdulaBubble
        presentViewController(viewController: schedulerBubble, isNavigationController: false)
    }
    
    func launchMediaRecorderComponent() {
        let cometChatMediaRecorder = UIStoryboard(name: "CometChatMediaRecorder", bundle: CometChatUIKit.bundle).instantiateViewController(identifier: "CometChatMediaRecorder") as? CometChatMediaRecorder
        DispatchQueue.main.async {
            let blurredView = cometChatMediaRecorder?.blurView(view: cometChatMediaRecorder?.view ?? UIView())
            cometChatMediaRecorder?.view.addSubview(blurredView!)
            cometChatMediaRecorder?.view.sendSubviewToBack(blurredView!)
        }
        if let cometChatMediaRecorder = cometChatMediaRecorder {
            presentViewController(viewController: cometChatMediaRecorder, isNavigationController: false)
        }
    }
}


class CustomImageView: UIView {
    
    private let imageView: UIImageView
    private let captionLabel: UILabel
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        captionLabel = UILabel()
        
        super.init(frame: frame)
        
        setupImageView()
        setupCaptionLabel()
    }
    
    required init?(coder: NSCoder) {
        imageView = UIImageView()
        captionLabel = UILabel()
        
        super.init(coder: coder)
        
        setupImageView()
        setupCaptionLabel()
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            imageView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    private func setupCaptionLabel() {
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.textAlignment = .center
        captionLabel.textColor = .black
        captionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(captionLabel)
        
        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            captionLabel.leftAnchor.constraint(equalTo: leftAnchor),
            captionLabel.rightAnchor.constraint(equalTo: rightAnchor),
            captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func setCaption(_ caption: String) {
        captionLabel.text = caption
    }
}

class CustomMessageComposer: UIView {
    
    var user: User?
    var group: Group?
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    
    init(user: User?, group: Group?) {
        self.user = user
        self.group = group
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Customize textView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.font = UIFont.systemFont(ofSize: 16)
        addSubview(textView)
        
        // Customize sendButton
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        addSubview(sendButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            textView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendButtonTapped() {
        guard let messageText = textView.text, !messageText.isEmpty else { return }
        if let user = user {
            // Send a message to the user
            let message = TextMessage(receiverUid: user.uid!, text: messageText, receiverType: .user)
            CometChatUIKit.sendTextMessage(message: message)
        } else if let group = group {
            // Send a message to the group
            let message = TextMessage(receiverUid: group.guid, text: messageText, receiverType: .group)
            CometChatUIKit.sendTextMessage(message: message)
        }
        textView.text = ""
    }
}


class BubbleImageView: UIView {
    
    private let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(bubbleImageView)
        addSubview(captionLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Bubble Image View Constraints
        NSLayoutConstraint.activate([
            bubbleImageView.topAnchor.constraint(equalTo: topAnchor),
            bubbleImageView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 100),
            bubbleImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bubbleImageView.bottomAnchor.constraint(equalTo: captionLabel.topAnchor, constant: -4),
            bubbleImageView.heightAnchor.constraint(equalToConstant: 250) // Adjust as needed
        ])
        
        // Caption Label Constraints
        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: bubbleImageView.leadingAnchor, constant: 8),
            captionLabel.trailingAnchor.constraint(equalTo: bubbleImageView.trailingAnchor, constant: -8),
            captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -8),
            captionLabel.heightAnchor.constraint(equalToConstant: 20) // Adjust as needed
        ])
    }
    
    // Public method to configure the view with data
    func configure(with image: UIImage, caption: String) {
        bubbleImageView.image = image
        captionLabel.text = caption
    }
}
