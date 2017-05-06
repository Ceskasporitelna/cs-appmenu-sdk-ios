//
//  AppItem.swift
//  CSAppMenuSDK
//
//  Created by Marty on 25/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


@objc public class AppItem: NSObject, NSCoding
{
    /**
     Application name
     */
    public let name: String
    /**
     icon link
     */
    public let iconUrl: String?
    /**
     X from X.2.3
     */
    public let minimalVersionMajor: String?
    /**
     X from 1.X.3
     */
    public let minimalVersionMinor: String?
    /**
     if app is outdated
     */
    public let incompatibleTextEN: String?
    /**
     if app is outdated
     */
    public let incompatibleTextCS: String?

    /**
     Get czech version of text for Application description.
     */
    public let descriptionTextCS:String?
    
    /**
     Get english version of text for Application description.
     */
    public let descriptionTextEN:String?
    
    
    /**
     Raw JSON data that may contain additional information about this app
     */
    public var rawData:[String:AnyObject]?
    
    /**
     itunes link
     */
    let itunesLink: String?
    public var itunesLinkURL: URL? {
        if let itunesLink = self.itunesLink,
            let url = URL(string: itunesLink) {
            return url
        }
        return nil
    }
    /**
     url scheme example cz.csas.quickcheck://
     */
    let urlScheme: String?
    public var urlSchemeURL: URL? {
        get{
            guard let scheme = self.urlScheme else {
                return nil
            }
            return URL(string: scheme )
        }
    }
    
    
    //MARK: -
    /**
     return true if application is installed on device
     */
    public func isInstalled()->Bool{
        guard let scheme = self.urlScheme else {
            return false
        }
        return canOpenUrl(scheme)
    }
    
    public func openApp(){
        openUrl(self.urlScheme)
    }
    
    public func openAppStorePage(){
        openUrl(self.itunesLink)
    }
    
    public func open(){
        if isInstalled(){
            self.openApp()
        }
        self.openAppStorePage()
    }
    
    
    //MARK: - appVersion
    public func appVersion()->AppVersion?{
        if minimalVersionMinor == nil || minimalVersionMajor == nil{
            return nil
        }
        return AppVersion(major: Int(self.minimalVersionMajor!), minor: Int(self.minimalVersionMinor!))
    }
    
    
    init?(app:Application)
    {
        guard let appName = app.appName , !appName.isEmpty else {
            return nil
        }
        
        self.name = appName
        self.iconUrl = app.appIconUrl
        self.minimalVersionMajor = app.minimalVersionMajor
        self.minimalVersionMinor = app.minimalVersionMinor
        self.incompatibleTextEN = app.incompatibleTextEN
        self.incompatibleTextCS = app.incompatibleTextCS
        self.itunesLink = app.itunesLink
        self.urlScheme = app.urlScheme
        self.rawData = app.rawData
        self.descriptionTextEN = app.descriptionTextEN
        self.descriptionTextCS = app.descriptionTextCS
    }
    
    //MARK: - NSCoding
    struct AppItemKeys{
        static let nameKey = "name"
        static let iconUrlKey = "iconUrlKey"
        static let urlSchemeKey = "urlScheme"
        static let itunesLinkKey = "itunesLink"
        static let incompatibleTextCSKey = "incompatibleTextCS"
        static let incompatibleTextENKey = "incompatibleTextEN"
        static let descriptionTextENKey = "descriptionTextEN"
        static let descriptionTextCSKey = "descriptionTextCS"
        static let minimalVersionMinorKey = "minimalVersionMinor"
        static let minimalVersionMajorKey = "minimalVersionMajor"
        static let rawDataKey = "rawData"
        
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        guard let _rawData = aDecoder.decodeObject(forKey: AppItemKeys.rawDataKey) as? Data else { return nil }
        guard let _rawDatasArray = NSKeyedUnarchiver.unarchiveObject(with: _rawData) as? [String:AnyObject]? else { return nil }
        guard let _name = aDecoder.decodeObject(forKey: AppItemKeys.nameKey) as? String else { return nil }
        guard let _urlScheme = aDecoder.decodeObject(forKey: AppItemKeys.urlSchemeKey) as? String else { return nil }
        guard let _itunesLink = aDecoder.decodeObject(forKey: AppItemKeys.itunesLinkKey) as? String else { return nil }
        
        self.rawData = _rawDatasArray
        self.name = _name
        self.urlScheme = _urlScheme
        self.itunesLink = _itunesLink

        self.iconUrl = aDecoder.decodeObject(forKey: AppItemKeys.iconUrlKey) as? String
        
        self.incompatibleTextCS = aDecoder.decodeObject(forKey: AppItemKeys.incompatibleTextCSKey) as? String
        self.incompatibleTextEN = aDecoder.decodeObject(forKey: AppItemKeys.incompatibleTextENKey) as? String
        
        self.minimalVersionMinor = aDecoder.decodeObject(forKey: AppItemKeys.minimalVersionMinorKey) as? String
        self.minimalVersionMajor = aDecoder.decodeObject(forKey: AppItemKeys.minimalVersionMajorKey) as? String
        
        self.descriptionTextCS = aDecoder.decodeObject(forKey: AppItemKeys.descriptionTextCSKey) as? String
        self.descriptionTextEN = aDecoder.decodeObject(forKey: AppItemKeys.descriptionTextENKey) as? String
        
        super.init()
    }
    
    public func encode(with aCoder: NSCoder)
    {
        if let incompatibleTextCS = self.incompatibleTextCS {
            aCoder.encode(incompatibleTextCS, forKey: AppItemKeys.incompatibleTextCSKey)
        }
        if let incompatibleTextEN = self.incompatibleTextEN {
            aCoder.encode(incompatibleTextEN, forKey: AppItemKeys.incompatibleTextENKey)
        }
        if let minimalVersionMinor = self.minimalVersionMinor {
            aCoder.encode(minimalVersionMinor, forKey: AppItemKeys.minimalVersionMinorKey)
        }
        if let minimalVersionMajor = self.minimalVersionMajor {
            aCoder.encode(minimalVersionMajor, forKey: AppItemKeys.minimalVersionMajorKey)
        }
        if let iconUrl = self.iconUrl {
            aCoder.encode(iconUrl, forKey: AppItemKeys.iconUrlKey)
        }
        if let itunesLink = self.itunesLink {
            aCoder.encode(itunesLink, forKey: AppItemKeys.itunesLinkKey)
        }
        if let descriptionTextCS = self.descriptionTextCS {
            aCoder.encode(descriptionTextCS, forKey: AppItemKeys.descriptionTextCSKey)
        }
        if let descriptionTextEN = self.descriptionTextEN {
            aCoder.encode(descriptionTextEN, forKey: AppItemKeys.descriptionTextENKey)
        }
        
        
        aCoder.encode(urlScheme, forKey: AppItemKeys.urlSchemeKey)
        aCoder.encode(name, forKey: AppItemKeys.nameKey)
        if self.rawData != nil{
            let data = NSKeyedArchiver.archivedData(withRootObject: self.rawData!)
            aCoder.encode(data, forKey: AppItemKeys.rawDataKey)
        }
    }
    
}

//--------------------------------------------------------------------
func canOpenUrl(_ urlScheme:String)->Bool
{
    if let url = URL(string:urlScheme){
        return UIApplication.shared.canOpenURL(url)
    }
    return false
}

func openUrl(_ urlScheme:String?)
{
    if urlScheme != nil{
        if let url = URL(string:urlScheme!){
            UIApplication.shared.openURL(url)
        }
    }
}


