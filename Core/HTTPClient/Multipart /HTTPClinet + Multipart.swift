//
//  HTTPClinet + Multipart.swift
//  Slite
//
//  Created by Efraim Budusan on 20.01.2022.
//

import Foundation

extension HTTPClient {
    
    
    func createUploadRequest(uploadServerURL: URL, parameters: [String : Any]? = nil,
                             headers: [String: String]? = nil, includeAPISettings: Bool = false,
                             multipart: MultipartUpload, uploadProgress: @escaping(_ progress: Double) -> Void) -> HTTPUploadRequest {
        // MARK: - TO DO
        //        var request = try! URLRequest(url: uploadServerURL, method: .post)
        //        request.timeoutInterval = 4*60
        //        return Alamofire.AF.upload(multipartFormData: { (multipartFormData) in
        //            for (key, value) in parameters ?? [:] {
        //                let stringValue = String(describing: value)
        //                multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
        //            }
        //            multipartFormData.append(multipart.data,
        //                                     withName: "file",
        //                                     fileName: multipart.fileName,
        //                                     mimeType: multipart.uploadScope.mimeType.rawValue)
        //        }, with: request).uploadProgress { progress in
        //            uploadProgress(progress.fractionCompleted)
        //        }
        return HTTPUploadRequest()
    }
    
}

extension HTTPClient {
    
    struct MultipartUpload {
        let data: Data
        let fileName: String
        let uploadScope: UploadScope
    }
}
