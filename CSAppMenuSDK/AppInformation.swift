//
//  AppInformation.swift
//  CSAppMenuSDK
//
//  Created by Marty on 22/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation




@objc public class AppInformation:NSObject, NSCoding
{
    /**
     Object describing this applictaion. It will be only present if categoryKey is set during the SDK initalization and only if the server returned it
     */
    public let thisApp: AppItem?
    /**
     Array of objects describing other applications
     */
    public let otherApps: [AppItem]
    /**
     indicates was this app information obtained from
     */
    public let source: AppInformationSource
    /**
     timestamp
     */
    public let downloadedAtTimestamp: TimeInterval
    
    
    init(thisApp : AppItem?, otherApps : [AppItem] ){
        self.thisApp = thisApp
        self.otherApps = otherApps
        self.source = .Server
        self.downloadedAtTimestamp = Date().timeIntervalSince1970
    }
    
    init(thisApp: AppItem?, otherApps: [AppItem], source: AppInformationSource, downloadedAtTimestamp: TimeInterval){
        self.thisApp = thisApp
        self.otherApps = otherApps
        self.source = source
        self.downloadedAtTimestamp = downloadedAtTimestamp
    }

    
    //MARK: - NSCoding
    struct AppInfoKeys{
        static let thisAppKey:String = "thisApp"
        static let otherAppsKey:String = "otherApps"
        static let timestampKey:String = "downloadedAtTimestamp"
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        guard let _thisApp = aDecoder.decodeObject(forKey: AppInfoKeys.thisAppKey) as? AppItem? else { return nil }
        guard let _otherAppsData = aDecoder.decodeObject(forKey: AppInfoKeys.otherAppsKey) as? Data else { return nil }
        guard let _otherApps = NSKeyedUnarchiver.unarchiveObject(with: _otherAppsData) as? [AppItem] else { return nil }

        self.thisApp = _thisApp
        self.otherApps = _otherApps
        self.source = .Cache
        self.downloadedAtTimestamp = aDecoder.decodeDouble(forKey: AppInfoKeys.timestampKey)
        super.init()
    }
    
    public func encode(with aCoder: NSCoder){
        aCoder.encode(self.downloadedAtTimestamp, forKey: AppInfoKeys.timestampKey)
        aCoder.encode(self.thisApp, forKey: AppInfoKeys.thisAppKey)
        let data = NSKeyedArchiver.archivedData(withRootObject: self.otherApps)
        aCoder.encode(data, forKey: AppInfoKeys.otherAppsKey)
    }
    
    /**
     Seconds since this app information has been obtained
     */
    public func timeIntervalSinceDownload()->TimeInterval
    {
        return Date().timeIntervalSince1970 - self.downloadedAtTimestamp
    }
    
}
