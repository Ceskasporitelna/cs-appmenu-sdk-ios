//
//  AppMenuResource.swift
//  CSAppMenuSDK
//
//  Created by Marty on 13/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import CSCoreSDK


open class ApplicationsResource: Resource, HasInstanceResource
{
    
    /**
     Retrieve application menu in flat structure
     
     - Parameter appIdentifier: Application identifier Example: queueing
     */
    public func withId(_ id: Any) -> ApplicationResource
    {
        return ApplicationResource(id: id, path: self.path, client: self.client)
    }
    
}


open class ApplicationResource: InstanceResource, ListEnabled
{
    
    /**
     List all app for a given app identifier
     */
    public func list(_ callback: @escaping (_ result:CoreResult<ListResponse<Application>>)->Void)
    {
        ResourceUtils.CallList(self, pathSuffix: "ios", parameters: nil, transform: WebApiTransform({ (obj) -> CoreResult<ListResponse<Application>> in
            switch obj{
                case .success(let s):
                let applications = s.0
                let response = s.1
                if let data = response.data as? [Dictionary<String,AnyObject>]{
                    for (index, app) in applications.items.enumerated(){
                        app.rawData = data[index]
                    }
                }
            default:
                break
            }
            return obj.toCoreResult()
        }), callback: callback)
    }
    
}
