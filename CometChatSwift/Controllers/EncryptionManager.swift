//
//  EncryptionManager.swift
//  CometChatSwift
//
//  Created by Prathmesh on 08/11/24.
//  Copyright © 2024 MacMini-03. All rights reserved.

//Newly written code
import Foundation
import VirgilE3Kit
import CometChatSDK

class EncryptionManager {
    
    static let shared = EncryptionManager()
    
    private var eThree: EThree?
    private var virgilToken: String?
    private var virgilIdentity: String?
    private let tag = "EncryptionManager"
    
    private init() {}
    
    public func initializeEncryptionManager(onSuccess: @escaping () -> Void,onFailed: @escaping (String?) -> Void) {
        getVirgilTokenAndIdentity(
            onSuccess: {[weak self] virgilToken, virgilIdentity in
                guard let strongSelf = self else {
                    print("EncryptionManager deallocated before initializeEncryption could be called.")
                    return
                }
                strongSelf.initializeEncryption(
                    virgilToken: virgilToken,
                    virgilIdentity: virgilIdentity,
                    onSuccess: {
                        print("entering into initializeEncryption")
                        strongSelf.registerUser(
                            onSuccess: {
                                print("\(strongSelf.tag): registerUserSuccess")
                                onSuccess()
                            },
                            onFailed: { error in
                                print("\(self?.tag ?? ""): registerUserFailed \(String(describing: error))")
                                if error?.contains("already") == true {
                                    if ((try? self?.eThree?.hasLocalPrivateKey() == true) != nil) {
                                        print("\(self?.tag ?? ""): private key already exists")
                                        onSuccess()
                                    } else {
                                        strongSelf.restorePrivateKey(
                                            onSuccess: { onSuccess() },
                                            onFailed: { onFailed($0) }
                                        )
                                    }
                                } else {
                                    strongSelf.backupPrivateKey(
                                        onSuccess: { onSuccess() },
                                        onFailed: { onFailed($0) }
                                    )
                                }
                            }
                        )
                    },
                    onFailed: { onFailed($0) }
                )
            },
            onFailed: { onFailed($0) }
            
        )
        
    }
    
    public func getVirgilTokenAndIdentity(
        onSuccess: @escaping (String, String) -> Void,
        onFailed: @escaping (String) -> Void
    ) {
        
        CometChat.callExtension(slug: "e2ee",type: .get,endPoint: "/v1/virgil-jwt",body: nil,onSuccess: { response in
            if let responseData = response as? [String: Any],
               let virgilToken = responseData["virgilToken"] as? String,
               let virgilIdentity = responseData["identity"] as? String {
                onSuccess(virgilToken, virgilIdentity)
            } else {
                
            }
        },onError: { error in
            onFailed(error?.errorDescription ?? "Failed to get Virgil token and identity")
        })
    }
    
    
    public func initializeEncryption(
        virgilToken: String,
        virgilIdentity: String,
        onSuccess: @escaping () -> Void,
        onFailed: @escaping (String?) -> Void
    ) {
        // Define the token callback as EThree.RenewJwtCallback
        let tokenCallback: EThree.RenewJwtCallback = { completion in
            completion(virgilToken, nil) // Provide the token and no error
        }
        
        do {
            let params = try EThreeParams(identity: virgilIdentity, tokenCallback: tokenCallback)
            eThree = try EThree(params: params)
            self.virgilIdentity = virgilIdentity
            onSuccess()
        } catch {
            onFailed("Failed to initialize EThree: \(error.localizedDescription)")
        }
    }
    
    
    public func registerUser(onSuccess: @escaping () -> Void, onFailed: @escaping (String?) -> Void) {
        eThree?.register { result in
            print("result print 3 \(String(describing: result?.localizedDescription))")
            self.backupPrivateKey(onSuccess: onSuccess, onFailed: onFailed)
            return
        }
    }
    
    public func backupPrivateKey(onSuccess: @escaping () -> Void, onFailed: @escaping (String?) -> Void) {
        guard let password = virgilIdentity else {
            onFailed("No identity found")
            return
        }
        eThree?.backupPrivateKey(password: password) { result in
            print("print result 2 \(String(describing: result?.localizedDescription))")
        }
    }
    
    public func restorePrivateKey(onSuccess: @escaping () -> Void, onFailed: @escaping (String?) -> Void) {
        guard let password = virgilIdentity else {
            onFailed("No identity found")
            return
        }
        eThree?.restorePrivateKey(password: password) { result in
            print("print result\(String(describing: result?.localizedDescription))")
        }
    }
    
    func encryptMessage(receiverId: String, messageToEncrypt: String,onComplete: @escaping (Any?) -> Void) {
        fetchVirgilIdentity(receiverId: receiverId, isGroup: false) { recipientIdentity in
            guard let recipientIdentity = recipientIdentity else {
                onComplete(nil)
                return
            }
            self.eThree?.findUsers(with: [recipientIdentity]) { findUsersResult, error in
                guard let findUsersResult = findUsersResult, error == nil else {
                    // Error handling here
                    print("exiting")
                    return
                }
        
                let encryptedMessage = try! self.eThree?.authEncrypt(text: messageToEncrypt, for: findUsersResult)
                onComplete(encryptedMessage)
            }
        }
    }
    func decryptMessage(encryptedMessage: String, senderId: String, onComplete: @escaping (String?) -> Void) {
        fetchVirgilIdentity(receiverId: senderId, isGroup: false) { senderIdentity in
            guard let senderIdentity = senderIdentity else {
                onComplete(nil)
                return
            }
            self.eThree?.findUsers(with: [senderIdentity]) { users, error in
                guard let users = users, error == nil else {
                    // Error handling here
                    print("exiting")
                    return
                }
                
                let originalText = try! self.eThree?.authDecrypt(text: encryptedMessage, from: users[senderIdentity])
                onComplete(originalText)
            }
        }
    }
    
    func encryptMedia(receiverId: String, message: String,onComplete: @escaping (Any?) -> Void) {
        fetchVirgilIdentity(receiverId: receiverId, isGroup: false) { recipientIdentity in
            guard let recipientIdentity = recipientIdentity else {
                onComplete(nil)
                return
            }
            
            self.eThree?.findUsers(with: [recipientIdentity]) { findUsersResult, error in
                guard let findUsersResult = findUsersResult, error == nil else {
                    print("FindUserResult not found")
                    return
                }
                let image = UIImage(named: message)
                if let imageData = image?.jpegData(compressionQuality: 1.0) {
                    do {
                        let encryptedData = try self.eThree?.authEncrypt(data: imageData, for: findUsersResult)
                        onComplete(encryptedData)
                    } catch {
                        print("Encryption error: \(error)")
                        onComplete(nil)
                    }
                }
            }
        }
        
    }
    
    func decryptMedia(encryptedData: Data?, senderId: String,onComplete: @escaping (Data?) -> Void) {
        fetchVirgilIdentity(receiverId: senderId, isGroup: false) { senderIdentity in
            guard let senderIdentity = senderIdentity else {
                onComplete(nil)
                return
            }
            
            self.eThree?.findUsers(with: [senderIdentity]) { users , error in
                guard let users = users, error == nil else {
                    // Handle error
                    print("Error finding users: \(String(describing: error))")
                    onComplete(nil)
                    return
                }
                
                let originalData = try! self.eThree?.authDecrypt(data: encryptedData!, from: users[senderIdentity])
                onComplete(originalData)
            }
        }
    }
        
        func fetchVirgilIdentity(receiverId: String, isGroup: Bool, onComplete: @escaping (String?) -> Void) {
            let body: [String: Any] = isGroup
            ? ["guids": [receiverId], "uids": []]
            : ["uids": [receiverId], "guids": []]
            
            CometChat.callExtension(slug: "e2ee", type: .get, endPoint: "/v1/virgil-jwt", body: body, onSuccess: { response in
                if let responseData = response as? [String: Any],
                   let virgilIdentity = responseData["identity"] as? String {
                    onComplete(virgilIdentity)
                } else {
                    print("Error parsing Virgil identity response")
                    onComplete(nil)
                }
            }, onError: { error in
                print("Fetch Virgil identity error: \(String(describing: error?.errorDescription))")
                onComplete(nil)
            })
        }
    }
    

