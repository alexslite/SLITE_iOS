//
//  URLSession + DataRequest.swift
//  Networking
//
//  Created by Efraim Budusan on 15.12.2021.
//

import Foundation
import Combine


class HTTPClient {
    
    let configuration: HTTPClientConfiguration
    var session: URLSession
    
    // Events
    let onCloseSession = PassthroughSubject<Void, Error>()
    
    init(configuration: HTTPClientConfiguration) {
        self.configuration = configuration
        self.session = URLSession(configuration: configuration.urlConfiguration)
    }
    
    /// The encoding to use for `Array` parameters.
    let arrayEncoding: ArrayEncoding = .brackets
    
    /// The encoding to use for `Bool` parameters.
    let boolEncoding: BoolEncoding = .numeric
    
    func create(request method: HTTPMethod,
                path: String,
                queryItems: [String: Any]? = nil,
                parameters: [String: Any]? = nil,
                headers: [String:String]? = nil,
                encoding: ParameterEncoding = .url) throws -> HTTPRequest {
        
        // Add the path component to the base URL
        var url = configuration.serverURL.appendingPathComponent(path)
        
        // Encode the query parameters into the url
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var items: [String: Any]?
            if encoding == .url {
                items = parameters
            } else {
                items = queryItems
            }
            if let items = items {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(items)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                if let parameterizedUrl = urlComponents.url {
                    url = parameterizedUrl
                }
            }
        }
        
        // Create the http request from the url
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set HTTP headers
        configuration.httpHeaders.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set the body of the HTTPRequest
        if let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        
        // Set content type based on the encoding mode
        request.setValue("Content-Type", forHTTPHeaderField: encoding.headerValue)
        return HTTPRequest(urlRequest: request, client: self)
    }
}

extension HTTPClient {
    
    enum HTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    
    enum ParameterEncoding {
        case json
        case url
        
        var headerValue: String {
            switch self {
            case .url:
                return "application/x-www-form-urlencoded; charset=utf-8"
            case .json:
                return "application/json"
            }
        }
    }
}

@available(iOS 14, *)
extension URLSession {
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
            let task = self.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: HTTPRequestError.invalidRequestResponse)
                }
            }
            task.resume()
        })
    }
}
