//
//  CodableCaching.swift
//  Slite
//
//  Created by Efraim Budusan on 21.01.2022.
//

import Foundation

/// Simple json caching storage, where each model is translated into json before saving
/// or viceversa
struct CodableCaching<T> {
    static var rootDirectory: String {
        return "Codable"
    }

    static var relativePath: NSString {
        let dirPath = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0] as NSString
        return dirPath.appendingPathComponent(CodableCaching.rootDirectory) as NSString
    }

    fileprivate let queue: DispatchQueue

    init(resourceID: String, queue: DispatchQueue) {
        self.filePath = CodableCaching.relativePath.appendingPathComponent(resourceID).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        self.queue = queue
    }

    var filePath: String!
    var fileName: String {
        return (filePath as NSString).lastPathComponent
    }

    func clearCache() {
        let path = filePath!
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            print("CodableCaching: Failed to delete file \(path)\n\(error)")
        }
    }

    static func deleteCachingDirectory() {
        let path = CodableCaching.relativePath
        do {
            try FileManager.default.removeItem(atPath: path as String)
        } catch let error as NSError {
            print("CodableCaching: Failed to delete file \(path)\n\(error)")
        }
    }
}

extension CodableCaching where T: Codable {
    /// load json file from disk and tranlate into an mappable object
    func loadFromFile() -> T? {
        let path = filePath as String
        print("CodableCaching: \(String(describing: T.self)) - Loading \(fileName) from file...")

        return queue.sync {
            do {
                guard let jsonData = try loadContentFromFile() else {
                    return nil
                }
                return try JSONDecoder().decode(T.self, from: jsonData)
            } catch let error as NSError {
                print("Failed to load JSON \(path)\n\(error)")
            }

            return nil
        }
    }


    /// will save object as json file on disk
    /// - on nil --> file is deleted
    func saveToFile(_ object: T?, async: Bool = true) {
        guard let object = object else {
            removeFile(path: filePath)
            return
        }

        let save = {
            do {
                let jsonData = try JSONEncoder().encode(object)
                try self.saveToFile(data: jsonData)
            }  catch let error as NSError {
                print("CodableCaching: ERROR saving: \(error)")
            }
        }

        print("CodableCaching: \(String(describing: T.self)) - Saving \'\(fileName)\' to file...")

        if async {
            queue.async(flags: .barrier, execute: {
                save()
            })
        } else {
            save()
        }
    }

    /// will save result, on success only, as json file on disk
    func saveToFile(result: Result<T>?) {
        if let object = result?.value {
            saveToFile(object)
        }
    }

    func removeFile() {
        removeFile(path: filePath)
    }
}



extension CodableCaching {
    fileprivate func loadContentFromFile() throws -> Data? {
        if FileManager.default.fileExists(atPath: filePath) == false {
            return nil
        }
        return try Data(contentsOf: URL(fileURLWithPath: filePath), options: [])
    }

    fileprivate func saveToFile(data: Data) throws {
        // Create directory if necessary
        let fileManager = FileManager.default
        let filePath = self.filePath as NSString
        if fileManager.fileExists(atPath: filePath.deletingLastPathComponent) == false {
            try fileManager.createDirectory(atPath: filePath.deletingLastPathComponent, withIntermediateDirectories: false, attributes: nil)
        }

        // write data
        try data.write(to: URL(fileURLWithPath: self.filePath))
    }

    fileprivate func removeFile(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path as String)
        } catch let error as NSError {
            print("CodableCaching: Failed to delete file \(path)\n\(error)")
        }
    }
}

