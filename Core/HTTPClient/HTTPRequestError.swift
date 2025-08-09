//
//  HTTPRequestError.swift
//  Networking
//
//  Created by Efraim Budusan on 19.01.2022.
//

import Foundation

enum HTTPRequestError: Error {
    case invalidHttpStatusCode
    case invalidRequestResponse
}
