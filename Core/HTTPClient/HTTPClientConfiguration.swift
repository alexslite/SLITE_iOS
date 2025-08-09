//
//  URLSession + Extensions.swift
//  Networking
//
//  Created by Efraim Budusan on 15.12.2021.
//

import Foundation

protocol HTTPClientConfiguration {
    
    var serverURL: URL { get }
    var urlConfiguration: URLSessionConfiguration { get }
    var validStatusCodes: ClosedRange<Int> { get }
    var closeSessionStatusCodes: [Int] { get }
    var httpHeaders: [String: String] { get }
    func decodedError(data: Data) throws -> Error?
}




