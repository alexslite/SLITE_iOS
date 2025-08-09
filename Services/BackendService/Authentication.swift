//
//  API.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

extension BackendService {
    
    @discardableResult
    static func register(_ email: String, password: String) async throws -> LoginSession {
        let params : [String: Any] = [ "email":email, "password": password]
        let request = try httpClient.create(request: .post, path: "/auth/register", parameters: params, encoding: .json)
        let session: LoginSession = try await request.decodedResponse()
        Session.saveSession(accessToken: session.token, userId: session.user.id)
        return session
    }
    
    @discardableResult
    static func loginWithEmail(_ email: String, password: String) async throws -> LoginSession {
        let params : [String: Any] = [ "email":email, "password": password]
        let request = try httpClient.create(request: .post, path: "/auth/register", parameters: params, encoding: .json)
        let session: LoginSession = try await request.decodedResponse()
        Session.saveSession(accessToken: session.token, userId: session.user.id)
        return session
    }
    
    static func logout() async throws  {
        let request = try httpClient.create(request: .post, path: "/auth/logout", encoding: .url)
        try await request.voidResponse()
    }
}
