//
//  AppMenuClient.swift
//  CSAppMenuSDK
//
//  Created by Marty on 13/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import CSCoreSDK


public class AppMenuClient: WebApiClient
{
    public var applications: ApplicationsResource {
        return ApplicationsResource(path:self.pathAppendedWith("appmenu"), client: self )
    }
    
    //MARK: -
    public override init(config: WebApiConfiguration, apiBasePath: String)
    {
        super.init(config: config, apiBasePath: "/api/v2")
    }
    
    public convenience init( config: WebApiConfiguration )
    {
        self.init( config: config, apiBasePath: "/api/v2")
    }
    
}
