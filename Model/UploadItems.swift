//
//  UploadItems.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

enum UploadScope: String {
    case profilePicture = "userProfilePicture"
    
    var mimeType: MimeType {
        switch self {
        case .profilePicture:
            return .jpegImage
        }
    }
}

enum MimeType: String {
    case jpegImage = "image/jpg"
}

let UploadImageMaxSize: UInt = 1600 // pixel
let JPEGCompressionQuality = 0.8

struct RequestUpload: Codable {
    let url: URL
    let fields: [String:String]
}
