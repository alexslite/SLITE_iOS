//
//  BackendServiceConfiguration.swift
//  Slite
//
//  Created by Efraim Budusan on 20.01.2022.
//

import Foundation
import UIKit

class BackendService {
    
    static var httpClient = HTTPClient(configuration: BackendService.ClientConfiguration())
}

extension BackendService {
    
    struct ClientConfiguration: HTTPClientConfiguration {

        let serverURL: URL = URL(string: "https://api.sandbox.wellory.com/")!
       
        let urlConfiguration: URLSessionConfiguration = {
            var config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30.0
            return config
        }()
        
        let validStatusCodes: ClosedRange<Int> = (200...299)
        let closeSessionStatusCodes: [Int] = [401, 403]

        var httpHeaders: [String: String] {
            var headers: [String: String] = [:]
            headers["User-Agent"] = userAgent
            return headers
        }
        
        private var userAgent: String {
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
            let osVersion = UIDevice.current.systemVersion
            let appName = "appName"
            return "ios \(osVersion) \(appName)/\(appVersion)"
        }
        
        func decodedError(data: Data) throws -> Error? {
            try? JSONDecoder().decode(BackendError.self, from: data)
        }
    }
}
