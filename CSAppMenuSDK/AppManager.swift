//
//  AppMenuApi.swift
//  CSSDKTestApp
//
//  Created by Vratislav Kalenda on 21/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import CSCoreSDK
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



public class AppManager: AppManagerApi
{
    public var checkForVersionInterval:TimeInterval = 12.0*60*60
    public var retryInterval:TimeInterval = 4.0
    
    public let appId:String!
    public let categoryKey:String?
    
    fileprivate var fakeMinVersion:(UInt, UInt)?
    
    fileprivate let webApiConfiguration : WebApiConfiguration
    fileprivate var client:AppMenuClient!
    
    fileprivate var isCheckingAppVersion:Bool = false
    fileprivate var versionCheckedAtTimestamp: TimeInterval?
    
    fileprivate var isDownloadingData:Bool = false
    
    fileprivate var appIsOutdatedCallback:((_ thisApp: AppItem)->Void)?
    fileprivate var loaderQueue:[((_ appInformation: AppInformation)->Void)] = []
    fileprivate var observingCallbacks:[String:((_ appInformation: AppInformation)->Void)] = [:]
    
    fileprivate let syncQueue: DispatchQueue!
    fileprivate var _completionQueue: DispatchQueue?
    public var completionQueue: DispatchQueue {
        get {
            return self._completionQueue ?? DispatchQueue.main
        }
        set {
            self._completionQueue = newValue
        }
    }
    
    fileprivate var appInformation:AppInformation?{
        didSet{
            if self.appInformation != nil {
                let data = NSKeyedArchiver.archivedData(withRootObject: self.appInformation!)
                UserDefaults.standard.set(data, forKey: self.appId)
            }
        }
    }
    
    
    init(appId:String!, categoryKey:String?, webApiConfiguration : WebApiConfiguration)
    {
        self.appId = appId
        self.categoryKey = categoryKey
        self.webApiConfiguration = webApiConfiguration
        
        self.client = AppMenuClient(config: self.webApiConfiguration)
        
        self.syncQueue = DispatchQueue(label:"CSAppMenuSDK.SerialQueue")
        self.attemptToLoadAppInfoFromDefaults()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func attemptToLoadAppInfoFromDefaults()
    {
        if self.appInformation == nil{
            DispatchQueue.main.async {
                if UIApplication.shared.isProtectedDataAvailable{
                    if let cachedAppInfoData:Data = UserDefaults.standard.object(forKey: self.appId) as? Data{
                        self.appInformation = NSKeyedUnarchiver.unarchiveObject(with: cachedAppInfoData) as? AppInformation
                    }
                }
            }
        }
    }
    
    //MARK: -allowMaxAgeInSeconds
    public func getAppInformation(allowMaxAgeInSeconds:TimeInterval, callback: @escaping ((_ appInformation: AppInformation)->Void))
    {
        self.syncQueue.async(execute: {
            
            self.attemptToLoadAppInfoFromDefaults()
            if self.appInformation != nil {
                if allowMaxAgeInSeconds > self.appInformation?.timeIntervalSinceDownload() {
                    self.callCallBack(callback)
                }else{
                    self.callCallBack(callback)
                    self.loadAppInfo(callback)
                }
            }else{
                self.loadAppInfo(callback)
            }
        })
    }
    
    fileprivate func loadAppInfo(_ callback: @escaping ((_ appInformation: AppInformation)->Void))
    {
        self.loaderQueue.append(callback)
        if !self.isDownloadingData{
            self.loadApps()
        }
    }
    
    fileprivate func callCallBack(_ callback: @escaping ((_ appInformation: AppInformation)->Void))
    {
        if self.appInformation != nil{
            self.completionQueue.async(execute: {
                
                callback(self.appInformation!)
            })
        }
    }
    
    //MARK: - load apps
    fileprivate func loadApps()
    {
        self.isDownloadingData = true
        self.client.applications.withId(self.appId).list { (result) in
            switch result{
            case .success(let apps):
                var otherApps:[AppItem] = []
                var thisApp:AppItem?
                for app in apps.items{
                    guard let iTunesLink = app.itunesLink,
                          let appName    = app.appName else {
                        continue
                    }
                    if !iTunesLink.isEmpty && !appName.isEmpty{
                        if app.categoryKey == self.categoryKey {
                            
                            if let minVersion = self.fakeMinVersion {
                                app.minimalVersionMajor = minVersion.0.description
                                app.minimalVersionMinor = minVersion.1.description
                            }
                            thisApp = AppItem(app: app)
                            
                        }else{
                            if let appItem = AppItem(app: app) {
                                otherApps.append(appItem)
                            }
                        }
                    }
                }
                let appInfo = AppInformation(thisApp: thisApp, otherApps: otherApps)
                self.isDownloadingData = false
                self.notifyForCallBack(appInfo)
                self.notifyLoaderQueue(appInfo)
                self.appInformation = AppInformation(thisApp: appInfo.thisApp, otherApps: appInfo.otherApps, source: .Cache, downloadedAtTimestamp: appInfo.downloadedAtTimestamp)
                
            case .failure(let error):
                clog(AppMenuSDK.ModuleName, activityName: AppMenuActivities.menuLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Menu loading error: \(error)" );
                self.syncQueue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(self.retryInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self.loadApps()
                })
            }
        }
    }
    
    fileprivate func notifyForCallBack(_ appInfo:AppInformation)
    {
        self.completionQueue.async(execute: {
            
            for tag in self.observingCallbacks.keys {
                if let callback:((_ appInformation: AppInformation)->Void) = self.observingCallbacks[tag]{
                    callback(appInfo)
                }
            }
        })
    }
    
    fileprivate func notifyLoaderQueue(_ appInfo:AppInformation)
    {
        self.completionQueue.async(execute: {
            
            for callback in self.loaderQueue {
                callback(appInfo)
            }
            self.loaderQueue.removeAll()
        })
    }
    
    //MARK: -
    public func registerAppInformationObtainedCallback(tag:String, callback: @escaping ((_ appInformation: AppInformation)->Void))
    {
        self.observingCallbacks[tag] = (callback)
        
        if self.appInformation != nil {
            self.completionQueue.async(execute: {
                callback(self.appInformation!)
            })
        }
    }
    
    public func unregisterAppInformationObtainedCallback(tag:String)
    {
        self.observingCallbacks.removeValue(forKey: tag)
    }
    
    public func unregisterAllAppInfomationObtainedCallbacks()
    {
        self.observingCallbacks.removeAll()
    }
    
    //MARK: -
    public func startCheckingAppVersion(_ appIsOutdatedCallback:@escaping ((_ thisApp: AppItem)->Void))
    {
        if !self.isCheckingAppVersion{
            self.isCheckingAppVersion = true
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
            
            self.appIsOutdatedCallback = appIsOutdatedCallback
            self.checkAppVersion()
        } else {
            assert(true, "You called checkingAppVersion for the second time! You can call it just once!")
            return
        }
    }
    
    public func fakeMinimalVersionFromServer(minVersion:(UInt, UInt)?)
    {
        self.fakeMinVersion = minVersion
    }
    
    @objc func applicationDidBecomeActiveNotification()
    {
        if let versionCheckedAtTimestamp = self.versionCheckedAtTimestamp{
            let checkDiffTime = Date().timeIntervalSince1970 - versionCheckedAtTimestamp
            
            if checkDiffTime > self.checkForVersionInterval {
                checkAppVersion()
            }
        }
    }
    
    fileprivate func checkAppVersion()
    {
        self.syncQueue.async(execute: {
            
            self.getAppInformation(allowMaxAgeInSeconds: 10)
            { (appInformation) in
                self.versionCheckedAtTimestamp = Date().timeIntervalSince1970
                if let thisApp = appInformation.thisApp{
                    
                    let currentVersion = AppVersion()
                    if let serverVersion = thisApp.appVersion(){
                        
                        let comparison = currentVersion.compare(serverVersion)
                        if comparison == ComparisonResult.orderedAscending{
                            self.completionQueue.async(execute: {
                                self.appIsOutdatedCallback?(thisApp)
                            })
                        }
                    }
                }
            }
        })
    }
    
}
