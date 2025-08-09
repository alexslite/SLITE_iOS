//
//  APIError.swift
//  Networking
//
//  Created by Sergiu Corbu on 26.11.2021.
//

import Foundation
import UIKit

extension Error {
    
    var isNewtorkConnectionError: Bool {
        let nsError = self as NSError
        return nsError.code == NSURLErrorNotConnectedToInternet
    }
}

struct BackendError: Decodable, Error {
    
    enum `Type`: String {
        case missingSession = "MissingSession"
        case unkown
        case invalidHttpStatusCode
        case userGenerated
        
        var asError: BackendError {
            return .init(type: self)
        }
    }
    
    let message: String
    let type: `Type`
    
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(message: String) {
        self.message = message
        self.type = .userGenerated
    }
    
    init(type: `Type`) {
        self.message = ""
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        type = .unkown
    }
    
}

extension BackendError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}

func ==(lhs: Error, rhs: BackendError.`Type`) -> Bool {
    switch lhs {
    case let error as BackendError:
        return error.type == rhs
    default:
        return false
    }
}

func ==(lhs: Error?, rhs: BackendError.`Type`) -> Bool {
    if let error = lhs {
        return error == rhs
    } else {
        return false
    }
}

func ==(lhs: BackendError, rhs: Error) -> Bool {
    return rhs == lhs.type
}

func ==(lhs: Error, rhs: BackendError) -> Bool {
    return lhs == rhs.type
}

