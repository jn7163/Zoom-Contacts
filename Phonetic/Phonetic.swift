//
//  Phonetic.swift
//  Phonetic
//
//  Created by Augus on 2/6/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import Contacts


let kQuickSearchKeyRawValue              = "kQuickSearchKeyRawValueRawValue"
let kAdditionalSettingsStatus            = "kAdditionalSettingsStatus"
let kEnableNickname                      = "kEnableNickname"
let kEnableCustomName                    = "kEnableCustomName"
let kOverwriteAlreadyExists              = "kOverwriteAlreadyExists"

let kEnableAllCleanPhonetic              = "kEnableAllCleanPhonetic"
let kCleanPhoneticNickname               = "kCleanPhoneticNickname"
let kCleanPhoneticMiddleName             = "kCleanPhoneticMiddleName"
let kCleanPhoneticDepartment             = "kCleanPhoneticDepartment"
let kCleanPhoneticCompany                = "kCleanPhoneticCompany"
let kCleanPhoneticJobTitle               = "kCleanPhoneticJobTitle"
let kCleanPhoneticPrefix                 = "kCleanPhoneticPrefix"
let kCleanPhoneticSuffix                 = "kCleanPhoneticSuffix"
let kCleanSocialProfilesKeys             = "kCleanSocialProfilesKeys"
let kCleanInstantMessageAddressesKeys    = "kCleanInstantMessageAddressesKeys"


let kEnableNicknameDefaultBool           = true
let kEnableCustomNameDefaultBool         = false
let kOverwriteAlreadyExistsDefaultBool   = false

let kEnableAllCleanPhoneticDefaultBool   = false
let kCleanPhoneticNicknameDefaultBool    = false
let kCleanPhoneticMiddleNameDefaultBool  = false
let kCleanPhoneticDepartmentDefaultBool  = false
let kCleanPhoneticCompanyDefaultBool     = false
let kCleanPhoneticJobTitleDefaultBool    = false
let kCleanPhoneticPrefixDefaultBool      = false
let kCleanPhoneticSuffixDefaultBool      = false
let kCleanSocialProfilesKeysDefaultBool  = false
let kCleanInstantMessageKeysDefaultBool  = false

struct Phonetic {
    var brief: String
    var value: String?
}

enum QuickSearch: Int {
    case MiddleName
    case Department
    case Company
    case JobTitle
    case Prefix
    case Suffix
    case Cancel
    
    var key: String {
        switch self {
        case .MiddleName:
            return NSLocalizedString("Middle Name", comment: "")
        case .Department:
            return NSLocalizedString("Department", comment: "")
        case .Company:
            return NSLocalizedString("Company", comment: "")
        case .JobTitle:
            return NSLocalizedString("Job Title", comment: "")
        case .Prefix:
            return NSLocalizedString("Prefix", comment: "")
        case .Suffix:
            return NSLocalizedString("Suffix", comment: "")
        case .Cancel:
            return NSLocalizedString("Cancel", comment: "")
        }
    }
}

enum PhoneticKeys: String {
    case Nickname
    case MiddleName
    case Department
    case Company
    case JobTitle
    case Prefix
    case Suffix
    case SocialProfiles
    case InstantMessageAddresses
    
    var key: String {
        switch self {
        case .Nickname:
            return NSLocalizedString("Nickname", comment: "")
        case .MiddleName:
            return NSLocalizedString("Middle Name", comment: "")
        case .Department:
            return NSLocalizedString("Department", comment: "")
        case .Company:
            return NSLocalizedString("Company", comment: "")
        case .JobTitle:
            return NSLocalizedString("Job Title", comment: "")
        case .Prefix:
            return NSLocalizedString("Prefix", comment: "")
        case .Suffix:
            return NSLocalizedString("Suffix", comment: "")
        case .SocialProfiles:
            return NSLocalizedString("Social Profiles", comment: "")
        case .InstantMessageAddresses:
            return NSLocalizedString("Instant Message Addresses", comment: "")
        }
    }
}