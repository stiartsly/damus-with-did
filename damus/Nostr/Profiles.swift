//
//  Profiles.swift
//  damus
//
//  Created by William Casarin on 2022-04-17.
//

import Foundation
import UIKit


class Profiles {
    var profiles: [String: TimestampedProfile] = [:]
    var validated: [String: NIP05] = [:]
    var zappers: [String: String] = [:]
    
    func is_validated(_ pk: String) -> NIP05? {
        return validated[pk]
    }
    
    func lookup_zapper(pubkey: String) -> String? {
        if let zapper = zappers[pubkey] {
            return zapper
        }
        
        return nil
    }
    
    func add(id: String, profile: TimestampedProfile) {
        print("add====>\(id),\(profile)")
        profiles[id] = profile
    }
    
    func lookup(id: String) -> Profile? {
        print("lookup====>\(id)")
        print("profiles[id]?.profile====>\(profiles[id]?.profile)")
        return profiles[id]?.profile
    }
    
    func lookup_with_timestamp(id: String) -> TimestampedProfile? {
        return profiles[id]
    }
}
