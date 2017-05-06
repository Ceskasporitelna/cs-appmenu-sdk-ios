//
//  AppMenuSDKApi.swift
//  CSAppMenuSDK
//
//  Created by Marty on 21/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//


public protocol AppMenuSDKApi
{
    /**
     AppMenuSDK shared instance, singleton.
     */
    static var sharedInstance: AppMenuSDKApi    { get }
    
    /**
     Configured AppManager that is able to obtain AppInformation and perform version checks
     */
    var appManager: AppManagerApi               { get }
    
    /**
     Configures the AppMenuSDK. This has to be called before using this SDK
     - parameter appId: Application id string that is used in the URL for fetching the relevant app information.
     
     - parameter categoryKey: If categoryKey is set, the SDK will try to find an AppItem with CATEGORY_KEY corresponding to this value and treat it as information about this particular application. This value is mandatory, if you want to run a version check.
     
     - returns: A configured AppMenuSDK.
     */
    func useAppMenu(appId:String, categoryKey: String?) -> AppMenuSDKApi
    
}


//--------------------------------------------------------------------------
public enum AppInformationSource : String
{
    /**
     Value indicating that the AppInformation has been obtained from the server recently
     */
    case Server = "SERVER"
    /**
     Value indicating that the AppInformation has been obtained from the cache
     */
    case Cache = "CACHE"
}


//--------------------------------------------------------------------------
public protocol AppManagerApi
{
    /**
     Afther app version check you can set how many seconds app should wait until next check for new version
     */
    var checkForVersionInterval:TimeInterval  { get set }
    /**
     If data request fail, how many seconds app should wait until next try
     */
    var retryInterval:TimeInterval            { get set }
    /**
     Application identifier in Česká Spořitelna name space example: queueing.
     */
    var appId:String!                          { get }
    /**
     Category key
     */
    var categoryKey:String?                    { get }
    /**
     You can specify queue where will be callbacks executed
     */
    var completionQueue: DispatchQueue       { get set }
    
    
    /**
     Retrieves AppInformation either from cache or the server and returns it thorugh the callback.
     The callback may be called TWICE. First when the AppInformation is returned from the cache (if present there) and then when the fresh data is returned from the server. The server download is trigerred when no data in cache are present or when the stored data is older than the allowMaxAgeInSeconds parameter specifies.
     AppManager will retry on callers behalf until it succeeds to obtain the requested AppInformation.
     Retry interval can be specified as a AppManager property RetryInterval
     */
    func getAppInformation(allowMaxAgeInSeconds:TimeInterval, callback: @escaping ((_ appInformation: AppInformation)->Void))
    
    /**
     Registers callback that will be invoked when new AppInformation data is downloaded, if there is any data in cache you will get it immediately.
     You can register multiple callbacks. They will be called in order of registration when the AppInformation is obtaind
     
     - parameter tag: tag of registering object
     */
    func registerAppInformationObtainedCallback(tag:String, callback: @escaping ((_ appInformation: AppInformation)->Void))
    
    /**
     Will remove reference registered callback
     
     - parameter tag: tag of unregistering object
     */
    func unregisterAppInformationObtainedCallback(tag:String)
    
    /**
     Will remove all reference to registered callbacks
     */
    func unregisterAllAppInfomationObtainedCallbacks()
    
    /**
     Checks the app version. This should be called only once in the application(application:, didFinishLaunchingWithOptions) method.
     The version is checked immidately after this method is called and then every 12 hours when UIApplicationDidBecomeActive event is fired, interval can be changed with property checkForVersionInterval.
     If the app version is outdated, a callback is fired.
     
     The SDK has to be configured with a categoryKey and your version in CFBundleShortVersionString must be in the format of MAJOR.MINOR in order for this check to work.
     
     If the check fails, AppManager will retry the check on callers behalf until it succeeds. Retry interval can be specified as a AppManager property retryInterval
     */
    func startCheckingAppVersion(_ appIsOutdatedCallback: @escaping ((_ thisApp: AppItem)->Void))
    
    /**
     Method for testing purposes, it will rewrite app version of the this app, so you will be able to test of func startCheckingAppVersion(appIsOutdatedCallback:((thisApp: AppItem)->Void)) behaviors
     */
    func fakeMinimalVersionFromServer(minVersion:(UInt, UInt)?)
    
}
