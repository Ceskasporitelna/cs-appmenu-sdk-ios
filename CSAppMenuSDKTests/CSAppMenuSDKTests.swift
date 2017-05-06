//
//  CSAppMenuSDKTests.swift
//  CSAppMenuSDKTests
//
//  Created by Marty on 13/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import XCTest
import CSCoreSDK

@testable import CSAppMenuSDK

class CSAppMenuSDKTests: XCTestCase {
    
    var client:AppMenuClient!
    var judgeSession:JudgeSession!
    
    override func setUp()
    {
        super.setUp()
        
        let config = WebApiConfiguration(webApiKey: "TEST_API_KEY", environment: Environment(apiContextBaseUrl: "\(Judge.BaseURL)/webapi", oAuth2ContextBaseUrl: ""), language: "cs-CZ", signingKey: nil)
        self.judgeSession = Judge.startNewSession()
        self.client = AppMenuClient(config: config)
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    //MARK: -
    func testParametersList()
    {
        self.judgeSession.setNextCase( "ios.appmenu.parameters.list", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        let expAppIconUrl = ["https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/quickcheck_iconIPhone.png","https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/servis24iconIPhone.png", "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/quickcheck_iconIPhone.png"]
        let expAppName = ["Queueing", "SERVIS 24", "Můj stav"]
        let expCategoryKey = ["QUEUEING", "SERVIS_24", "QUICKCHECK"]
        let expItunesLink = ["https://itunes.apple.com/us/app/muj-stav/id961068799", "https://itunes.apple.com/us/app/servis-24-mobilni-banka/id469812727", "https://itunes.apple.com/us/app/muj-stav/id961068799"]
        let expUrlScheme = ["cz.csas.queueing://", "service24://", "cz.csas.app.mujstav://"]
        let expIncompatibleTextCS:[String?] = ["Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim.", nil ,"Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim."]
        let expMinimalVersionMinor:[String?] = ["1", nil, "0"]
        let expIncompatibleTextEN:[String?] = ["This is an unsupported version of application, please update.", nil ,"This is an unsupported version of application, please update."]
        let expMinimalVersionMajor:[String?] = ["1", nil, "0"]
        let expDescriptionTextCS:[String?] = [nil,nil,"Rychlý náhled na Váš účet"]
        let expDescriptionTextEN:[String?] = [nil,nil,"EN Rychly nahled na Vas ucet"]
        
        
        let expRawData:[[String:String]?] = [["incompatibleTextCS": "Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim.",
                                                 "app_icon": "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/quickcheck_iconIPhone.png",
                                                 "app_name": "Queueing",
                                                 "category_key": "QUEUEING",
                                                 "minimalVersionMinor": "1",
                                                 "incompatibleTextEN": "This is an unsupported version of application, please update.",
                                                 "minimalVersionMajor": "1",
                                                 "itunes_link": "https://itunes.apple.com/us/app/muj-stav/id961068799", "url_scheme": "cz.csas.queueing://"],
                                                ["app_icon": "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/servis24iconIPhone.png","app_name": "SERVIS 24", "category_key": "SERVIS_24","itunes_link": "https://itunes.apple.com/us/app/servis-24-mobilni-banka/id469812727","url_scheme": "service24://"],
                                                ["incompatibleTextCS": "Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim.",
                                                 "app_icon": "https://www.csas.cz/static_internet/cs/Redakce/Prezentace/Automaticky_rozbalit/Prilohy/mobileapps/mobileApps/queing/quickcheck_iconIPhone.png",
                                                 "app_name": "Můj stav",
                                                 "category_key": "QUICKCHECK",
                                                 "minimalVersionMinor": "0",
                                                 "incompatibleTextEN": "This is an unsupported version of application, please update.",
                                                 "minimalVersionMajor": "0",
                                                 "itunes_link": "https://itunes.apple.com/us/app/muj-stav/id961068799",
                                                 "url_scheme": "cz.csas.app.mujstav://",
                                                 "descriptionTextCS" : "Rychlý náhled na Váš účet",
                                                 "descriptionTextEN" : "EN Rychly nahled na Vas ucet"
                                                ]
                                        ]
        
        self.client.applications.withId("queueing").list { (result) in
            switch result{
            case .success(let apps):
                for (index, app) in apps.items.enumerated() {
                    XCTAssertEqual(app.appName , expAppName[index])
                    XCTAssertEqual(app.urlScheme, expUrlScheme[index])
                    XCTAssertEqual(app.appIconUrl, expAppIconUrl[index])
                    XCTAssertEqual(app.itunesLink, expItunesLink[index])
                    XCTAssertEqual(app.categoryKey, expCategoryKey[index])
                    XCTAssertEqual(app.incompatibleTextCS , expIncompatibleTextCS[index])
                    XCTAssertEqual(app.incompatibleTextEN, expIncompatibleTextEN[index])
                    XCTAssertEqual(app.minimalVersionMajor, expMinimalVersionMajor[index])
                    XCTAssertEqual(app.minimalVersionMinor, expMinimalVersionMinor[index])
                    XCTAssertEqual(app.descriptionTextCS, expDescriptionTextCS[index])
                    XCTAssertEqual(app.descriptionTextEN, expDescriptionTextEN[index])
                    if let expRawData = expRawData[index] {
                        for rawDataKey in app.rawData!.keys{
                            XCTAssertEqual(app.rawData![rawDataKey]! as! String, expRawData[rawDataKey]! )
                        }
                    }else{
                        XCTFail()
                    }
                }
                expectation.fulfill()
                
            case .failure(let error):
                print(error.localizedDescription)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    

}

