//
//  User.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

struct User: Codable {
    var id: String
    var email: String
    var firstName : String?
    var lastName : String?
    
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
    }
}

struct LoginSession: Decodable {
    let user: User
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case user
        case token = "authToken"
    }
}

