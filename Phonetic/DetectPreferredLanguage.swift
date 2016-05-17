//
//  DetectPreferredLanguage.swift
//  Phonetic
//
//  Created by Augus on 2/15/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import Foundation


struct DetectPreferredLanguage {
    
    static var isChineseLanguage: Bool {
        guard let langCode = NSLocale.preferredLanguages().first else { return false }
        return isChineseLanguage(langCode)
    }
    
    static var isSimplifiedChinese: Bool {
        guard let langCode = NSLocale.preferredLanguages().first else { return false }
        return langCode.containsString("zh-Hans")
    }
    
    // ["zh-Hant-US", "en-US", "zh-Hans-US", "zh-HK", "zh-TW"]
    private static func isChineseLanguage(id: String) -> Bool {
        
        guard !id.containsString("zh-Hans") else { return true } // Chinese Mandrain
        guard !id.containsString("zh-TW")   else { return true } // Taiwan
        guard !id.containsString("zh-HK")   else { return true } // HongKong
        guard !id.containsString("zh-Hant") else { return true } // HongKong
        
        return false
    }
    
}