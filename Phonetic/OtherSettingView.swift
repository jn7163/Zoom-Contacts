//
//  OtherSettingView.swift
//  Phonetic
//
//  Created by Augus on 1/30/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices
import Device

class OtherSettingView: UIStackView, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate {
    
    private var picker: MFMailComposeViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        addGestureRecognizer(recognizer)
        
        configureFollowingIcon()
    }
    
    internal func viewDidTap() {
        parentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // simulate highlight
            for view in self.subviews {
                if let img = view as? UIImageView {
                    img.simulateHighlight()
                    break
                }
            }
            
            switch self.tag {
            case 0: // Twitter
                self.followMe()
            case 1: // Rate
                OtherSettingView.RateMe()
            case 2: // Feedback
                self.sendMail()
            default: break
            }
        })
    }
    
    private func configureFollowingIcon() {
        
        let imageName = DetectPreferredLanguage.isSimplifiedChinese ? "weibo" : "twitter"
        let image = UIImage(named: imageName)
        
        _ = subviews.map() {
            if $0.tag == 999 && $0 is UIImageView {
                ($0 as! UIImageView).image = image
            }
        }
    }
    
    
    // MARK: - follow me on Twitter or Weibo
    
    private func followMe() {
        if DetectPreferredLanguage.isSimplifiedChinese {
            followMeOnWeibo()
        } else {
            followMeOnTwitter()
        }
    }
    
    private func followMeOnTwitter() {
        
        let tweetbotURL = NSURL(string: "tweetbot://iAugux/user_profile/iAugux")
        let twitterURL = NSURL(string: "twitter://user?screen_name=iAugux")
        
        let urls = [tweetbotURL, twitterURL]
        
        for url in urls {
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
                return
            }
        }
        
        let safariVC = SFSafariViewController(URL: NSURL(string: "https://twitter.com/iAugux")!)
        safariVC.delegate = self
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        UIApplication.topMostViewController?.presentViewController(safariVC, animated: true, completion: nil)
    }
    
    private func followMeOnWeibo() {
        
        let id = "1778865900"
        
        /// I love `VVebo`, but... you know... Fuck Sina
        
        /// What's the url scheme of WeicoPro?
        /// com.weico.weicopro4://???
        /// weico3://???
        
        let mokeURL = NSURL(string: "moke:///user?id=" + id)
        let weiboURL = NSURL(string: "sinaweibo://userinfo?uid=" + id)
        
        let urls = [mokeURL, weiboURL]
        
        for url in urls {
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
                return
            }
        }
        
        let safariVC = SFSafariViewController(URL: NSURL(string: "http://weibo.com/augusoo7")!)
        safariVC.delegate = self
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        UIApplication.topMostViewController?.presentViewController(safariVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Rate me
    
    static func RateMe() {
        let appURL = NSURL(string: "https://itunes.apple.com/app/viewContentsUserReviews?id=1109288786")
        if UIApplication.sharedApplication().canOpenURL(appURL!) {
            UIApplication.sharedApplication().openURL(appURL!)
        }
    }
    
    
    // MARK: - feedback with Mail
    
    private func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            picker = MFMailComposeViewController()
            picker?.mailComposeDelegate = self
            picker?.setToRecipients(["iAugux@gmail.com"])
            picker?.setSubject("Zoom Contacts Feedback")
            
            if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
                if let build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String {
                    let info = "# V \(version) (\(build)), \(Device.version()), iOS \(UIDevice.currentDevice().systemVersion) #\n"
                    picker?.setMessageBody(info, isHTML: true)
                    UIApplication.topMostViewController?.presentViewController(picker!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true) { () -> Void in
            self.picker = nil
        }
    }
    
}