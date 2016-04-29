//
//  PhoneticContacts.swift
//  Phonetic
//
//  Created by Augus on 1/28/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit
import Contacts


class PhoneticContacts {
    
    static let sharedInstance = PhoneticContacts()
    
    init() {
        DEBUGLog("Register UserNotificationSettings & UIApplicationDidBecomeActiveNotification")
        
        // register user notification settings
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhoneticContacts.reinstateBackgroundTask), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    let contactStore = CNContactStore()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var contactsTotalCount: Int!
    
    var keysToFetch: [String] {
        var keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneticGivenNameKey, CNContactPhoneticFamilyNameKey]
        
        if let CNContactQuickSearchKey = ContactKeyForQuickSearch {
            keys.append(CNContactQuickSearchKey)
        }
        
        keys.appendContentsOf(keysToFetchIfNeeded)
        
        return keys
    }
    
    var isProcessing = false {
        didSet {
            if isProcessing {
                registerBackgroundTask()
            } else {
                endBackgroundTask()
            }
        }
    }
    
    private var aborted = false
    
    private lazy var backgroundTask = UIBackgroundTaskInvalid
    
    private lazy var localNotification: UILocalNotification = {
        let localNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        return localNotification
    }()
    
    
    typealias ResultHandler = ((currentResult: String?, percentage: Double) -> Void)
    typealias AccessGrantedHandler = (() -> Void)
    typealias CompletionHandler = ((aborted: Bool) -> Void)
    
    func execute(handleAccessGranted: AccessGrantedHandler, resultHandler:  ResultHandler, completionHandler: CompletionHandler) {
        AppDelegate().requestContactsAccess { (accessGranted) in
            guard accessGranted else { return }
            
            // got the access...
            handleAccessGranted()
        }
        
        contactsTotalCount = getContactsTotalCount
        
        isProcessing = true
        aborted      = !isProcessing
        
        // uncomment the following line if you want to remove all Simulator's Contacts first.
        //        self.removeAllContactsOfSimulator()
        
        self.insertNewContactsForSimulatorIfNeeded(50)
        //                self.insertNewContactsForDevice(100)
        
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            
            var index = 1
            let count = self.contactsTotalCount
            
            do {
                try self.contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: self.keysToFetch), usingBlock: { (contact, _) -> Void in
                    
                    guard self.isProcessing else {
                        self.aborted = true
                        return
                    }
                    
                    if !contact.familyName.isEmpty || !contact.givenName.isEmpty {
                        let mutableContact: CNMutableContact = contact.mutableCopy() as! CNMutableContact
                        
                        var familyName          = ""
                        var givenName           = ""
                        var phoneticFamilyBrief = ""
                        var phoneticGivenBrief  = ""
                        
                        var shouldAddQuickSearchKey = false
                        
                        // modify Contact
                        if let family = mutableContact.valueForKey(CNContactFamilyNameKey) as? String {
                            
                            familyName = family
                            
                            if let phoneticFamily = self.phonetic(family, needFix: self.fixPolyphonicCharacters) {
                                phoneticFamilyBrief  = phoneticFamily.brief
                                
                                if self.antiPhonetic(family) {
                                    shouldAddQuickSearchKey = true
                                }
                            }
                        }
                        
                        if let given = mutableContact.valueForKey(CNContactGivenNameKey) as? String {
                            
                            givenName = given
                            
                            if let phoneticGiven = self.phonetic(given, needFix: false) {
                                phoneticGivenBrief  = phoneticGiven.brief

                                if self.antiPhonetic(given) {
                                    shouldAddQuickSearchKey = true
                                }
                            }
                        }
                        
                        if shouldAddQuickSearchKey {
                            
                            self.addPhoneticNameForQuickSearchIfNeeded(mutableContact, familyBrief: phoneticFamilyBrief, givenBrief: phoneticGivenBrief)
                            
                            self.saveContact(mutableContact)
                            
                            let result = familyName + givenName + "「" + phoneticFamilyBrief + phoneticGivenBrief + "」"
                            
                            self.handlingResult(resultHandler, result: result, index: index, total: count)
                        }
                        
                        index += 1
                    }
                })
            } catch {
                
                DEBUGLog("fetching Contacts failed ! - \(error)")
            }
            
            self.isProcessing = false
            
            self.handlingCompletion(completionHandler)
        }
        
    }
    
    func cleanMandarinLatinPhonetic(handleAccessGranted: AccessGrantedHandler, resultHandler: ResultHandler, completionHandler: CompletionHandler) {
        AppDelegate().requestContactsAccess { (accessGranted) in
            guard accessGranted else { return }
            
            // got the access...
            handleAccessGranted()
        }
        
        contactsTotalCount = getContactsTotalCount
        
        isProcessing = true
        aborted = !isProcessing
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            
            var index = 1
            let count = self.contactsTotalCount
            
            do {
                try self.contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: self.keysToFetch), usingBlock: { (contact, _) -> Void in
                    
                    guard self.isProcessing else {
                        self.aborted = true
                        return
                    }
                    
                    let mutableContact: CNMutableContact = contact.mutableCopy() as! CNMutableContact
                    
                    // modify Contact
                    /// only clean who has Mandarin Latin.
                    /// Some english names may also have phonetic keys which you don't want to be cleaned.
                    
                    var shouldClean = false
                    
                    if let family = mutableContact.valueForKey(CNContactFamilyNameKey) as? String {
                        if self.antiPhonetic(family) {
                            shouldClean = true
                        }
                    }
                    
                    if let given = mutableContact.valueForKey(CNContactGivenNameKey) as? String {
                        if self.antiPhonetic(given) {
                            shouldClean = true
                        }
                    }
                    
                    if shouldClean {
                        self.removePhoneticKeysIfNeeded(mutableContact)
                        self.saveContact(mutableContact)
                    }
                    
                    self.handlingResult(resultHandler, result: nil, index: index, total: count)
                    
                    index += 1
                })
            } catch {
                
                DEBUGLog("fetching Contacts failed ! - \(error)")
            }
            
            self.isProcessing = false
            
            self.handlingCompletion(completionHandler)
        }
    }
    
    var getContactsTotalCount: Int {
        let predicate = CNContact.predicateForContactsInContainerWithIdentifier(contactStore.defaultContainerIdentifier())
        
        do {
            let contacts = try self.contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey])
            return contacts.count
        } catch {
            
            DEBUGLog("\(error)")
            
            return 0
        }
    }
    
    private func handlingCompletion(handle: CompletionHandler) {
        
        switch UIApplication.sharedApplication().applicationState {
        case .Background:
            // completed not aborted
            if !aborted {
                DEBUGLog("Mission Completed")
                
                localNotification.fireDate = NSDate()
                localNotification.alertBody = NSLocalizedString("Mission Completed !", comment: "Local Notification - alert body")
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
        default:
            break
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            handle(aborted: self.aborted)
        })
    }
    
    private func handlingResult(handle: ResultHandler, result: String?, index: Int, total: Int) {
        
        let percentage = currentPercentage(index, total: total)
        
        switch UIApplication.sharedApplication().applicationState {
        case .Active:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                handle(currentResult: result, percentage: percentage)
            })
            
        case .Background:
            
            // set icon badge number as current percentage.
            UIApplication.sharedApplication().applicationIconBadgeNumber = Int(percentage)
            
            // handling results while it is almost complete to correct the UI of percentage.
            if percentage > 95 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    handle(currentResult: result, percentage: percentage)
                })
            }
            
            let remainingTime = UIApplication.sharedApplication().backgroundTimeRemaining
            
            // App is about to be terminated, send notification.
            if remainingTime < 10 {
                localNotification.fireDate = NSDate()
                localNotification.alertBody = NSLocalizedString("Phonetic is about to be terminated! Please open it again to complete the mission.", comment: "Local Notification - App terminated notification")
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
            
            DEBUGLog("Background time remaining \(remainingTime) seconds")
            
        default: break
        }
        
    }
    
    private func saveContact(contact: CNMutableContact) {
        let saveRequest = CNSaveRequest()
        saveRequest.updateContact(contact)
        do {
            try self.contactStore.executeSaveRequest(saveRequest)
        } catch {
            
            DEBUGLog("saving Contact failed ! - \(error)")
        }
    }
    
    private func currentPercentage(index: Int, total: Int) -> Double {
        let percentage = Double(index) / Double(total) * 100
        return min(percentage, 100)
    }
    
    
    /**
     Checking whether there is any Mandarin Latin. If yes, return true, otherwise return false
     
     - parameter str: Source string
     
     - returns: is there any Mandarin Latin
     */
    private func antiPhonetic(str: String) -> Bool {
        let str = str as NSString
        for i in 0..<str.length {
            let word = str.characterAtIndex(i)
            if word >= 0x4e00 && word <= 0x9fff {
                return true
            }
        }
        return false
    }
    
    private func upcaseInitial(str: String) -> String {
        var tempStr = str
        if str.utf8.count > 0 {
            tempStr = (str as NSString).substringToIndex(1).uppercaseString.stringByAppendingString((str as NSString).substringFromIndex(1))
        }
        return tempStr
    }
    
    private func briefInitial(array: [String]) -> String {
        guard array.count > 0 else { return "" }
        
        var tempStr = ""
        for str in array {
            if str.utf8.count > 0 {
                tempStr += (str as NSString).substringToIndex(1).uppercaseString
            }
        }
        
        return tempStr
    }
    
    private func phonetic(str: String, needFix: Bool) -> Phonetic? {
        var source = needFix ? manaullyFixPolyphonicCharacters(str).mutableCopy() : str.mutableCopy()
        
        CFStringTransform(source as! CFMutableStringRef, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(source as! CFMutableStringRef, nil, kCFStringTransformStripCombiningMarks, false)
        
        var brief: String
        
        if !(source as! NSString).isEqualToString(str) {
            
            if source.rangeOfString(" ").location != NSNotFound {
                
                let phoneticParts = source.componentsSeparatedByString(" ")
                source = NSMutableString()
                brief = briefInitial(phoneticParts)

            } else {
                brief = briefInitial([source as! String])
            }
            
            return Phonetic(brief: brief, value: nil)
        }
        return nil
    }
    
}


// MARK: - Background Task

private extension PhoneticContacts {
    
    @objc func reinstateBackgroundTask() {
        if isProcessing && (backgroundTask == UIBackgroundTaskInvalid) {
            registerBackgroundTask()
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        DEBUGLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}


extension PhoneticContacts {

    private var fixPolyphonicCharacters: Bool {
        return userDefaults.getBool(kFixPolyphonicChar, defaultKeyValue: kFixPolyphonicCharDefaultBool)
    }
    
}

