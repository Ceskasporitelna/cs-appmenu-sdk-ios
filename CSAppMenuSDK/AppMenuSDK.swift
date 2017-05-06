//
//  AppMenuSDK.swift
//  CSAppMenuSDK
//
//  Created by Marty on 21/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import CSCoreSDK

/**
 * Core log activities.
 */
//==============================================================================
internal enum AppMenuActivities: String {
    
    case menuLoading         = "MenuLoading"
}

public class AppMenuSDK: NSObject, AppMenuSDKApi{

    internal static let ModuleName      = "AppMenu"
    
    fileprivate var _appManager: AppManagerApi?
    
    
    public var appManager: AppManagerApi
    {
        assert(_appManager != nil, "You have to call useAppMenu method first")
        return _appManager!
    }
    
    public class var sharedInstance: AppMenuSDKApi
    {
        return _sharedInstance
    }

    fileprivate static let _sharedInstance = AppMenuSDK()
    
    public func useAppMenu(appId:String, categoryKey: String?) -> AppMenuSDKApi
    {
        self._appManager = AppManager(appId: appId,
                                     categoryKey: categoryKey,
                                     webApiConfiguration: CoreSDK.sharedInstance.webApiConfiguration)
        
        return self
    }
    
    fileprivate override init()
    {
        super.init()
    }

}
