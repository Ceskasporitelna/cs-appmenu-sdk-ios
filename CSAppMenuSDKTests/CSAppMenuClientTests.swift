//
//  CSAppMenuClientTests.swift
//  CSAppMenuSDK
//
//  Created by Marty on 27/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import XCTest
import CSCoreSDK

@testable import CSAppMenuSDK

class CSAppMenuClientTests: XCTestCase {
    
    var client:AppMenuClient!
    var judgeSession:JudgeSession!
    var appManager:AppManager!
    
    
    override func setUp()
    {
        super.setUp()
        
        let config = WebApiConfiguration(webApiKey: "TEST_API_KEY", environment: Environment(apiContextBaseUrl: "\(Judge.BaseURL)/webapi", oAuth2ContextBaseUrl: ""), language: "cs-CZ", signingKey: nil)
        self.judgeSession = Judge.startNewSession()
        self.client = AppMenuClient(config: config)
        
        self.appManager = AppManager(appId: "queueing",
                                     categoryKey: "QUEUEING",
                                     webApiConfiguration: config)
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    //MARK: -
    func testRegisterForCallback()
    {
        self.judgeSession.setNextCase( "ios.appmenu.parameters.list", xcTestCase: self)
        let expectation1 = expectation(description: "Callback1 expectation")
        let expectation2 = expectation(description: "Callback2 expectation")
        let expectation3 = expectation(description: "Callback3 expectation")
        
        let expAppName = ["SERVIS 24", "Můj stav"]
        
        self.appManager.registerAppInformationObtainedCallback(tag: "test1") { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            expectation1.fulfill()
        }
        
        self.appManager.registerAppInformationObtainedCallback(tag: "test2") { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            expectation2.fulfill()
        }
        
        self.appManager.getAppInformation(allowMaxAgeInSeconds: 0, callback: { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            expectation3.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    
    func testRegisterUnregisterForCallback()
    {
        self.judgeSession.setNextCase( "ios.appmenu.parameters.list", xcTestCase: self)
        let expectation1 = expectation(description: "Callback1 expectation")
        var expectation1b:XCTestExpectation?
        let expectation2 = expectation(description: "Callback2 expectation")
        let expectation3 = expectation(description: "Callback3 expectation")
        
        let expAppName = ["SERVIS 24", "Můj stav"]
        
        var flag1 = true
        var flag2 = true
        
        self.appManager.registerAppInformationObtainedCallback(tag: "test1") { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            
            if flag1 {
                flag1 = false
                expectation1.fulfill()
            }else{
                expectation1b!.fulfill()
            }
        }
        
        self.appManager.registerAppInformationObtainedCallback(tag: "test2") { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            expectation2.fulfill()
        }
        
        self.appManager.getAppInformation(allowMaxAgeInSeconds: 0, callback: { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            if flag2{
                flag2 = false
            }else{
                XCTFail()
            }
            expectation3.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler:nil)
        
        ///
        self.judgeSession.setNextCase( "ios.appmenu.parameters.list", xcTestCase: self)
        expectation1b = expectation(description: "Callback1b expectation")
        let expectation4s = expectation(description: "Callback4 server expectation")
        let expectation4c = expectation(description: "Callback4 cache expectation")
        
        self.appManager.unregisterAppInformationObtainedCallback(tag: "test2")
        
        self.appManager.getAppInformation(allowMaxAgeInSeconds: 0, callback: { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
            }
            if appInformation.source == .Server{
                expectation4s.fulfill()
            }
            if appInformation.source == .Cache{
                expectation4c.fulfill()
            }
        })
        
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testGetAppInfoServerCache()
    {
        self.judgeSession.setNextCase( "ios.appmenu.parameters.list", xcTestCase: self)
        let expectationServer = expectation(description: "Source server expectation")
        let expectationCache = expectation(description: "Source cashe expectation")
        
        self.appManager.getAppInformation(allowMaxAgeInSeconds: 0, callback: { (appInformation) in
            
            if appInformation.source == .Server{
                expectationServer.fulfill()
            }else{
                XCTFail()
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.appManager.getAppInformation(allowMaxAgeInSeconds: 1000, callback: { (appInformation) in
                
                if appInformation.source == .Cache{
                    expectationCache.fulfill()
                }else{
                    XCTFail()
                }
            })
        }
        
        waitForExpectations(timeout: 12.0, handler:nil)
    }
    
    func testStartCheckingAppVersion()
    {
        self.judgeSession.setNextCase( "ios.appmenu.parameters.list", xcTestCase: self)
        let expectation = self.expectation(description: "Expectation")
        
        let expVersion = 1
        self.appManager.startCheckingAppVersion { (thisApp) in
            let version = thisApp.appVersion()
            XCTAssertEqual(expVersion, version?.major)
            XCTAssertEqual(expVersion, version?.minor)
            expectation.fulfill()
        }
        
        self.appManager.startCheckingAppVersion { (thisApp) in
            XCTAssertTrue(true)
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testStartCheckingAppVersionAppBecomeActive()
    {
        self.judgeSession.setNextCase( "ios.appmenu.checkAppVersion", xcTestCase: self)
        let expectation = self.expectation(description: "Expectation")
        let expectationBecomeActive = self.expectation(description: "Expectation - become active")
        
        var flag = true
        
        let expVersion = 1
        self.appManager.startCheckingAppVersion { (thisApp) in
            let version = thisApp.appVersion()
            XCTAssertEqual(expVersion, version?.major)
            XCTAssertEqual(expVersion, version?.minor)
            
            if flag {
                flag = false
                expectation.fulfill()
                
            }else{
                expectationBecomeActive.fulfill()
            }
        }
        
        self.appManager.checkForVersionInterval = 3
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(4 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            
            NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }
        
        waitForExpectations(timeout: 15.0, handler:nil)
    }
    
    func testgetAppInformationServerCache()
    {
        self.judgeSession.setNextCase( "ios.appmenu.checkAppVersion", xcTestCase: self)
        let expectationS = expectation(description: "Expectation server")
        
        let expectationC = expectation(description: "Expectation cache")
        
        
        let expAppIconUrl = ["https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/servis24iconIPhone.png", "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/quickcheck_iconIPhone.png"]
        let expAppName = ["SERVIS 24", "Můj stav"]
        let expItunesLink = ["https://itunes.apple.com/us/app/servis-24-mobilni-banka/id469812727", "https://itunes.apple.com/us/app/muj-stav/id961068799"]
        let expUrlScheme = ["service24://", "cz.csas.app.mujstav://"]
        let expIncompatibleTextCS:[String?] = [nil ,"Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim."]
        let expMinimalVersionMinor:[String?] = [nil, "0"]
        let expIncompatibleTextEN:[String?] = [nil ,"This is an unsupported version of application, please update."]
        let expMinimalVersionMajor:[String?] = [nil, "0"]
        let expDescriptionTextCS:[String?] = [nil,nil,"Rychlý náhled na Váš účet"]
        let expDescriptionTextEN:[String?] = [nil,nil,"EN Rychly nahled na Vas ucet"]
        
        
        let expRawData:[[String:String]?] = [["app_icon": "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/servis24iconIPhone.png",
                                              "app_name": "SERVIS 24",
                                              "category_key": "SERVIS_24",
                                              "itunes_link": "https://itunes.apple.com/us/app/servis-24-mobilni-banka/id469812727",
                                              "url_scheme": "service24://"],
                                                ["incompatibleTextCS": "Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim.",
                                                 "app_icon": "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/quickcheck_iconIPhone.png",
                                                 "app_name": "Můj stav", "category_key": "QUICKCHECK",
                                                 "minimalVersionMinor": "0",
                                                 "incompatibleTextEN": "This is an unsupported version of application, please update.",
                                                 "minimalVersionMajor": "0",
                                                 "itunes_link": "https://itunes.apple.com/us/app/muj-stav/id961068799",
                                                 "url_scheme": "cz.csas.app.mujstav://",
                                                 "descriptionTextCS": "Rychlý náhled na Váš účet",
                                                 "descriptionTextEN": "EN Rychly nahled na Vas ucet"]]
        
        
        self.appManager.getAppInformation(allowMaxAgeInSeconds: 0, callback: { (appInformation) in
            
            for (index, app) in appInformation.otherApps.enumerated(){
                XCTAssertEqual(app.name , expAppName[index])
                XCTAssertEqual(app.urlScheme, expUrlScheme[index])
                XCTAssertEqual(app.iconUrl, expAppIconUrl[index])
                XCTAssertEqual(app.itunesLink, expItunesLink[index])
                XCTAssertEqual(app.incompatibleTextCS , expIncompatibleTextCS[index])
                XCTAssertEqual(app.incompatibleTextEN, expIncompatibleTextEN[index])
                XCTAssertEqual(app.minimalVersionMajor, expMinimalVersionMajor[index])
                XCTAssertEqual(app.minimalVersionMinor, expMinimalVersionMinor[index])
                XCTAssertEqual(app.descriptionTextCS, expDescriptionTextCS[index])
                XCTAssertEqual(app.descriptionTextEN, expDescriptionTextEN[index])
                if let expRawData = expRawData[index] {
                    for rawDataKey in app.rawData!.keys{
                        XCTAssertEqual(app.rawData![rawDataKey] as! String, expRawData[rawDataKey]!)
                    }
                }else{
                    XCTFail()
                }
            }
            
            if appInformation.source == .Server{
                expectationS.fulfill()
            }else{
                XCTFail()
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(4 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            
            self.appManager.getAppInformation(allowMaxAgeInSeconds: 99999, callback: { (appInformation) in
                
                for (index, app) in appInformation.otherApps.enumerated(){
                    XCTAssertEqual(app.name , expAppName[index])
                    XCTAssertEqual(app.urlScheme, expUrlScheme[index])
                    XCTAssertEqual(app.iconUrl, expAppIconUrl[index])
                    XCTAssertEqual(app.itunesLink, expItunesLink[index])
                    XCTAssertEqual(app.incompatibleTextCS , expIncompatibleTextCS[index])
                    XCTAssertEqual(app.incompatibleTextEN, expIncompatibleTextEN[index])
                    XCTAssertEqual(app.minimalVersionMajor, expMinimalVersionMajor[index])
                    XCTAssertEqual(app.minimalVersionMinor, expMinimalVersionMinor[index])
                    if let expRawData = expRawData[index] {
                        for rawDataKey in app.rawData!.keys{
                            XCTAssertEqual(app.rawData![rawDataKey] as? String, expRawData[rawDataKey]!)
                        }
                    }else{
                        XCTFail()
                    }
                }
                
                if appInformation.source == .Cache{
                    expectationC.fulfill()
                }else{
                    XCTFail()
                }
            })
            
        }
        
        waitForExpectations(timeout: 15.0, handler:nil)
    }
    
    //MARK: -
    func testNeedUpdate()
    {
        let localVersion = AppVersion(major: 1, minor: 1)
        let serverVersion = AppVersion(major: 2, minor: 2)
        
        if localVersion == serverVersion{
            XCTFail()
        }
        let comparison = localVersion.compare(serverVersion)
        
        if comparison == ComparisonResult.orderedAscending{
            print("ok")
        }else{
            XCTFail()
        }
    }
    
    
}
