//
//  Application.swift
//  CSAppMenuSDK
//
//  Created by Marty on 13/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import CSCoreSDK


public class Application : WebApiEntity
{
    /**
     Application name
     */
    public internal(set) var appName:String?
    
    /**
     url scheme to public app from link, example cz.csas.quickcheck://
     */
    public internal(set) var urlScheme:String?
    
    /**
     url to app icon
     */
    public internal(set) var appIconUrl:String?
    
    /**
     link to itunes
     */
    public internal(set) var itunesLink:String?
    
    /**
     category key
     */
    public internal(set) var categoryKey:String!
    
    /**
     message if app is outdated, in Czech, example: Mate jiz nepodporovanou verzi aplikace, aktualizujte prosim.
     */
    public internal(set) var incompatibleTextCS:String?
    
    /**
     message if app is outdated, in English, example This is an unsupported version of application, please update.
     */
    public internal(set) var incompatibleTextEN:String?
    
    /**
    X from X.2.3
     */
    public internal(set) var minimalVersionMajor:String?
    
    /**
     X from 1.X.3
     */
    public internal(set) var minimalVersionMinor:String?
    
    /**
     Get czech version of text for Application description.
     */
    public internal(set) var descriptionTextCS:String?
    
    /**
     Get english version of text for Application description.
     */
    public internal(set) var descriptionTextEN:String?
    
    /**
     Raw JSON data that may contain additional information about this app
     */
    public var rawData:[String:AnyObject]?
    
    
    //MARK: - Mappable
    public required init?(_ map: Map)
    {
        super.init(map)
    }
    
    public override func mapping(_ map: Map)
    {
        self.incompatibleTextCS     <- map["incompatibleTextCS"]
        self.incompatibleTextEN     <- map["incompatibleTextEN"]
        self.descriptionTextCS      <- map["descriptionTextCS"]
        self.descriptionTextEN      <- map["descriptionTextEN"]
        self.minimalVersionMinor    <- map["minimalVersionMinor"]
        self.minimalVersionMajor    <- map["minimalVersionMajor"]
        self.categoryKey            <- map["category_key"]
        self.appIconUrl             <- map["app_icon"]
        self.urlScheme              <- map["url_scheme"]
        self.itunesLink             <- map["itunes_link"]
        self.appName                <- map["app_name"]
        
        super.mapping(map)
    }
    
}

