//
//  CSAppVersion.swift
//  CSAppMenuSDK
//
//  Created by Marty on 14/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

public class AppVersion: NSObject
{
    public var major: Int?
    public var minor: Int?
    
    
    override init()
    {
        if let infoDictionary = Bundle.main.infoDictionary{
            if let bundleShortVersion = infoDictionary["CFBundleShortVersionString"] as? String{
                let parts = bundleShortVersion.components(separatedBy: ".")
                
                if parts.count > 0 {
                    self.major = Int(parts[0])
                }
                if parts.count > 1 {
                    self.minor = Int(parts[1])
                }
            }
        }
    }
    
    init(major: Int?, minor: Int?)
    {
        self.major  = major
        self.minor  = minor
    }
    
    //MARK: comparable
    open override func isEqual(_ object: Any?) -> Bool
    {
        if let appVersion = object as? AppVersion {
            if self.minor == appVersion.minor && self.major == appVersion.major {
                return true
            }
        }
        return false
    }
    
    func compare(_ object: AppVersion) -> ComparisonResult
    {
        if self.isEqual(object) {
            return .orderedSame
        }
        
        guard let major = self.major, let minor = self.minor else {
            return .orderedAscending
        }
        
        guard let omajor = object.major, let ominor = object.minor else {
            return .orderedDescending
        }
        
        if major > omajor || major == omajor && minor > ominor || major == omajor && minor == ominor {
            return .orderedDescending
        }
        return .orderedAscending
    }
    
}
