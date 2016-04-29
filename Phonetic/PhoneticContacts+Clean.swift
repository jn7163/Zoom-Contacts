//
//  PhoneticContacts+Clean.swift
//  Phonetic
//
//  Created by Augus on 2/13/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import Foundation
import Contacts

extension PhoneticContacts {
    
    var keysToFetchIfNeeded: [String] {
        var keys = [String]()
        
        if shouldCleanPhoneticNicknameKeys { keys.append(CNContactNicknameKey) }
        
        if shouldCleanPhoneticMiddleNameKeys { keys.append(CNContactPhoneticMiddleNameKey) }
        
        if shouldCleanPhoneticDepartmentKeys { keys.append(CNContactDepartmentNameKey) }
        
        if shouldCleanPhoneticCompanyKeys { keys.append(CNContactOrganizationNameKey) }
        
        if shouldCleanPhoneticJobTitleKeys { keys.append(CNContactJobTitleKey) }
        
        if shouldCleanPhoneticPrefixKeys { keys.append(CNContactNamePrefixKey) }
        
        if shouldCleanPhoneticSuffixKeys { keys.append(CNContactNameSuffixKey) }
        
        if shouldCleanSocialProfilesKeys { keys.append(CNContactSocialProfilesKey) }
        
        if shouldCleanInstantMessageAddressesKeys{ keys.append(CNContactInstantMessageAddressesKey) }
        
        return keys
    }
    
    func removePhoneticKeysIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticNicknameIfNeeded(mutableContact)
        removePhoneticMiddleNameIfNeeded(mutableContact)
        removePhoneticDepartmentKeysIfNeeded(mutableContact)
        removePhoneticCompanyKeysIfNeeded(mutableContact)
        removePhoneticJobTitleKeysIfNeeded(mutableContact)
        removePhoneticPrefixKeysIfNeeded(mutableContact)
        removePhoneticSuffixKeysIfNeeded(mutableContact)
        removeSocialProfilesKeysIfNeeded(mutableContact)
        removeInstantMessageAddressesKeysIfNeeded(mutableContact)
    }
    
    private func removePhoneticNicknameIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticNicknameKeys, key: CNContactNicknameKey)
    }
    
    private func removePhoneticMiddleNameIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticMiddleNameKeys, key: CNContactPhoneticMiddleNameKey)
    }
    
    private func removePhoneticDepartmentKeysIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticDepartmentKeys, key: CNContactDepartmentNameKey)
    }
    
    private func removePhoneticCompanyKeysIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticCompanyKeys, key: CNContactOrganizationNameKey)
    }
    
    private func removePhoneticJobTitleKeysIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticJobTitleKeys, key: CNContactJobTitleKey)
    }
    
    private func removePhoneticPrefixKeysIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticPrefixKeys, key: CNContactNamePrefixKey)
    }
    
    private func removePhoneticSuffixKeysIfNeeded(mutableContact: CNMutableContact) {
        removePhoneticKeysIfNeeded(mutableContact, shouldClean: shouldCleanPhoneticSuffixKeys, key: CNContactNameSuffixKey)
    }
    
    private func removeSocialProfilesKeysIfNeeded(mutableContact: CNMutableContact) {
        removeKeysArrayIfNeeded(mutableContact, shouldClean: shouldCleanSocialProfilesKeys, key: CNContactSocialProfilesKey)
    }
    
    private func removeInstantMessageAddressesKeysIfNeeded(mutableContact: CNMutableContact) {
        removeKeysArrayIfNeeded(mutableContact, shouldClean: shouldCleanInstantMessageAddressesKeys, key: CNContactInstantMessageAddressesKey)
    }
    
    private func removePhoneticKeysIfNeeded(mutableContact: CNMutableContact, shouldClean: Bool, key: String) {
        
        guard shouldClean else { return }
        
        if let _ = mutableContact.valueForKey(key) as? String {
            mutableContact.setValue("", forKey: key)
        }
    }
    
    private func removeKeysArrayIfNeeded(mutableContact: CNMutableContact, shouldClean: Bool, key: String) {
        
        guard shouldClean, let _ = mutableContact.valueForKey(key) as? NSArray else { return }
        
        mutableContact.setValue([], forKey: key)
    }
    
}

extension PhoneticContacts {
    
    private var shouldCleanPhoneticNicknameKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticNickname, defaultKeyValue: kCleanPhoneticNicknameDefaultBool)
    }
    
    private var shouldCleanPhoneticMiddleNameKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticMiddleName, defaultKeyValue: kCleanPhoneticMiddleNameDefaultBool)
    }
    
    private var shouldCleanPhoneticDepartmentKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticDepartment, defaultKeyValue: kCleanPhoneticDepartmentDefaultBool)
    }
    
    private var shouldCleanPhoneticCompanyKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticCompany, defaultKeyValue: kCleanPhoneticCompanyDefaultBool)
    }
    
    private var shouldCleanPhoneticJobTitleKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticJobTitle, defaultKeyValue: kCleanPhoneticJobTitleDefaultBool)
    }
    
    private var shouldCleanPhoneticPrefixKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticPrefix, defaultKeyValue: kCleanPhoneticPrefixDefaultBool)
    }
    
    private var shouldCleanPhoneticSuffixKeys: Bool {
        return shouldCleanPhoneticKey(kCleanPhoneticSuffix, defaultKeyValue: kCleanPhoneticSuffixDefaultBool)
    }
    
    // MARK: - Social Profiles Key
    private var shouldCleanSocialProfilesKeys: Bool {
        return shouldCleanPhoneticKey(kCleanSocialProfilesKeys, defaultKeyValue: kCleanSocialProfilesKeysDefaultBool)
    }
    
    // MARK: - Instant Message Addresses Key
    private var shouldCleanInstantMessageAddressesKeys: Bool {
        return shouldCleanPhoneticKey(kCleanInstantMessageAddressesKeys, defaultKeyValue: kCleanInstantMessageKeysDefaultBool)
    }
    
    // MARK: -
    private func shouldCleanPhoneticKey(key: String, defaultKeyValue: Bool) -> Bool {
        return userDefaults.getBool(key, defaultKeyValue: defaultKeyValue)
    }
    
}

extension PhoneticContacts {
    
    internal var messageOfCurrentKeysNeedToBeCleaned: String {
        var str = ""
        
        if shouldCleanPhoneticNicknameKeys ||
            shouldCleanPhoneticMiddleNameKeys ||
            shouldCleanPhoneticDepartmentKeys ||
            shouldCleanPhoneticCompanyKeys ||
            shouldCleanPhoneticJobTitleKeys ||
            shouldCleanPhoneticPrefixKeys ||
            shouldCleanPhoneticSuffixKeys ||
            shouldCleanSocialProfilesKeys ||
            shouldCleanInstantMessageAddressesKeys {
                str = NSLocalizedString(" And clean following keys you've chosen?", comment: "")
        }
        
        str += NSLocalizedString(" This can not be revoked!!", comment: "")
        str += "\n\n"
        
        if shouldCleanPhoneticNicknameKeys { str.append(PhoneticKeys.Nickname.key) }
        if shouldCleanPhoneticMiddleNameKeys { str.append(PhoneticKeys.MiddleName.key) }
        if shouldCleanPhoneticDepartmentKeys { str.append(PhoneticKeys.Department.key) }
        if shouldCleanPhoneticCompanyKeys { str.append(PhoneticKeys.Company.key) }
        if shouldCleanPhoneticJobTitleKeys { str.append(PhoneticKeys.JobTitle.key) }
        if shouldCleanPhoneticPrefixKeys { str.append(PhoneticKeys.Prefix.key) }
        if shouldCleanPhoneticSuffixKeys { str.append(PhoneticKeys.Suffix.key) }
        if shouldCleanSocialProfilesKeys { str.append(PhoneticKeys.SocialProfiles.key) }
        if shouldCleanInstantMessageAddressesKeys{ str.append(PhoneticKeys.InstantMessageAddresses.key) }
        
        str = String(str.characters.dropLast(2))
        
        return String(format: str)
    }
}

extension String {
    
    private mutating func append(str: String) {
        self += str + "\n\n"
    }
}

extension PhoneticContacts {
    
    //    func removePhoneticNicknameForTestFlightUsersToFixPreviousBug(mutableContact: CNMutableContact) {
    //
    //        guard Config.appConfiguration == .TestFlight || Config.appConfiguration == .Debug else { return }
    //
    //        if let _ = mutableContact.valueForKey(CNContactNicknameKey) as? String {
    //            mutableContact.setValue("", forKey: CNContactNicknameKey)
    //        }
    //    }
    
}