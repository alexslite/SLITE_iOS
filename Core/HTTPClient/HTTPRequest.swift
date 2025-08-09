//
//  HTTPRequest.swift
//  Networking
//
//  Created by Efraim Budusan on 18.01.2022.
//

import Foundation

struct HTTPRequest {
    
    let urlRequest: URLRequest
    let client: HTTPClient
    
    func validate(response: URLResponse, data: Data?) throws {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw HTTPRequestError.invalidHttpStatusCode
        }
        let apiError: Error? = data.flatMap {
            try? client.configuration.decodedError(data: $0)
        }
        guard client.configuration.validStatusCodes.contains(statusCode) else {
            
            print("\n Request failed: ",
                  urlRequest.httpMethod ?? "",
                  urlRequest.url?.absoluteString ?? "",
                  "\n\tResponse: " + (data.flatMap({ String(data:$0, encoding: .utf8) }) ?? ""))
            
            let noSession = apiError == .missingSession
            let accessDenied = client.configuration.closeSessionStatusCodes.contains(statusCode) || noSession
            if accessDenied {
                DispatchQueue.main.async {
                    if let error = apiError {
                        client.onCloseSession.send(completion: .failure(error))
                    } else {
                        client.onCloseSession.send()
                    }
                }
            }
            throw apiError ?? HTTPRequestError.invalidHttpStatusCode
        }
        if let error = apiError {
            throw error
        }
    }
    
    func voidResponse() async throws {
        let (data, response): (Data, URLResponse) = try await client.session.data(for: urlRequest)
        try validate(response: response, data: data)
    }
    
    func decodedResponse<T: Decodable>(keyPath: String? = nil, decoder: JSONDecoder = .default) async throws -> T {
        let (data, response): (Data, URLResponse) = try await client.session.data(for: urlRequest)
        try validate(response: response, data: data)
        do {
            var object: T
            if let keyPath = keyPath {
                object = try decoder.decode(T.self, from: data, keyPath: keyPath, separator: ".")
            } else {
                object = try decoder.decode(T.self, from: data)
            }
            return object
        } catch (let error as DecodingError) {
            print(error.debugDescription)
            throw error
        } catch {
            print("unknown error", error.localizedDescription)
            throw error
        }
    }
}

