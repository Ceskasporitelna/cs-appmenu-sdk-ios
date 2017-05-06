# Using AppMenuSDK

This usage guide walks you through a process of initializing AppMenuSDK and check for other apps and deciding whether or not your app is outdated.

## Before You Begin

Before using any SDK in your application, you need to initialize CoreSDK by providing it your WebApiKey.

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        CoreSDK.sharedInstance
            .useWebApiKey("YourApiKey")
            .useEnvironment(Environment.Sandbox)
        //Now you are ready to obtain the AppMenu client
        let client = AppMenuSDK.sharedInstance.client;
        return true
    }
```

## Usage

This usage guide walks you through a process of initializing AppMenuSDK and check for other apps and deciding if your app is outdated.

### Initialization

Before you will start using AppMenu you need to init your app endpoint by calling `useAppMenu` method.

```swift
AppMenuSDK.sharedInstance.useAppMenu(appId:"friends24", // name of app in Česká spořitelna a.s. systém
                                           categoryKey: "FRIENDS24") // category
      // As a first thing you have to call this endpoint to set up app manager

      AppMenuSDK.sharedInstance.appManager
      // Now you can will ba able to call methods of AppManager
```

### Checking if your application is outdated

You can check if user has installed latest version of the application. In your `AppDelegate` call `startCheckingAppVersion` method, but you should call it only once. App version will be checked immediately and then every 12 hours after the `UIApplicationDidBecomeActive` event fires. You can also set the `checkForVersionInterval` to custom value.

```swift
AppMenuSDK.sharedInstance.useAppMenu(appId: "friends24", categoryKey: "FRIENDS24").appManager
     .startCheckingAppVersion(  ////appmanager immediately checks if your application is outdated and then every time within checkForVersionInterval value when the UIApplicationDidBecomeActive event fires.
                { (thisApp) in  //when callback is fired it means your app is outdated

                    if let navigationController:UINavigationController = self.window!.rootViewController as? UINavigationController {

                        if let activeViewCont = navigationController.visibleViewController{  //geting visibleViewController
                            let alertController = UIAlertController(title: "Upozornění" , message:"Vaše aplikace není již aktualní", preferredStyle: .Alert)

                            let actAction = UIAlertAction(title: "Aktualizovat", style: .Default) {
                                (action) in
                                if let url = thisApp.itunesLinkURL {
                                    UIApplication.sharedApplication().openURL(url)
                                }
                            }
                            alertController.addAction(actAction)

                            let cancelAction = UIAlertAction(title: "Zrušit", style: .Default) {
                                (action) in
                            }
                            alertController.addAction(cancelAction)

                            activeViewCont.presentViewController(alertController, animated: true) {}
                        }
                    }
            })
```

#### Testing startCheckingAppVersion

For testing puposes is there a function `fakeMinimalVersionFromServer(minVersion minVersion:(UInt, UInt)?)`, if you set a non nil value next time when new applications data will be downloaded, this app `AppItem` object will have values of `minimalVersionMajor` and `minimalVersionMinor` set by touple.

### Get AppInformation

You will get [`AppInformation`](../CSAppMenuSDK/AppInformation.swift) of the endpoint. It contains information about both your app and other apps in [`AppItem`](../CSAppMenuSDK/AppItem.swift) type. It also contains download time stamp and source mark:

- Server - Information is fresh
- Cache - Information is older but still valid

You can specify how old the data can be (in seconds).

```swift
// passing pararameter allowMaxAgeInSeconds with value 5 means it's ok to return cached data that has been updated less than 5 seconds if data are older refresh them.
        AppMenuSDK.sharedInstance.appManager.getAppInformation(allowMaxAgeInSeconds: 5, callback:
            { (appInformation) in
                self.appInfo = appInformation
                //
        })
```

### Register callback to be notified when new AppInformation is obtained

You can call registerAppInformationObtainedCallback method to be notified when new [`AppInformation`](../CSAppMenuSDK/AppInformation.swift) is obtained, if there is any data in cache you will get it immediately. Choose you unique tag to identify your callback for later unregistering.

```swift
AppMenuSDK.sharedInstance.appManager.registerAppInformationObtainedCallback(tag: self.callbackTag, callback:
            { (appInformation) in
                self.appInfo = appInformation
        })
```

You have to call `unregisterAppInformationObtainedCallback` method when you want to dispose of a view controller otherwise it will never be deallocated.

```swift
AppMenuSDK.sharedInstance.appManager.unregisterAppInformationObtainedCallback(tag: self.callbackTag)
```

You can also remove all registered callbacks.

```swift
AppMenuSDK.sharedInstance.appManager.unregisterAllAppInfomationObtainedCallbacks()
```

### Specifing completion queue

You can specify completion queue, by default `dispatch_get_main_queue` is used.

## Demo

Check out the [demo application](https://github.com/Ceskasporitelna/csas-sdk-demo-ios) for usage demonstration.

## Further documentation

You can look into the source code of this repository to see documented classes and methods of this SDK.

This SDK communicates with AppMenu. You can have a look at its [documentation](http://docs.ext0csasapplications.apiary.io/#reference/appmenu).
