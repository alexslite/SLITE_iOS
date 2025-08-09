//
//  ImageUpload.swift
//  Slite
//
//  Created by Efraim Budusan on 20.01.2022.
//

import Foundation

extension BackendService {

    static func uploadPicture(multipartUpload: HTTPClient.MultipartUpload) async throws -> Void {
        let requestUpload = httpClient.createUploadRequest(uploadServerURL: httpClient.configuration.serverURL, multipart: multipartUpload, uploadProgress: { progress in
            
        })
        try await requestUpload.voidResponse()
    }

}
