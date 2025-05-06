//
//  ProfileModel.swift
//  LocalChat
//
//  Created by Maks Tsarevich on 29.03.24.
//

import UIKit

class ProfileModel: Decodable {
    
    var isAdmin = false
    var name = ""
    var login = ""
    var color = ""
    
    enum CodingKeys: String, CodingKey {
        case isAdmin
        case name
        case login
        case color
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isAdmin = try values.decodeIfPresent(Bool.self, forKey: .isAdmin) ?? false
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        login = try values.decodeIfPresent(String.self, forKey: .login) ?? ""
        color = try values.decodeIfPresent(String.self, forKey: .color) ?? ""
    }
}
