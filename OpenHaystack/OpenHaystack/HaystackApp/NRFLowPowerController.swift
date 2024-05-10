//
//  OpenHaystack – Tracking personal Bluetooth devices via Apple's Find My network
//
//  Copyright © 2021 Secure Mobile Networking Lab (SEEMOO)
//  Copyright © 2021 The Open Wireless Link Project
//
//  SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

struct NRFLowPowerController {

    static var tempDir: URL?
    
    static var nrfFirmwareDirectory: URL? {
        Bundle.main.resourceURL?.appendingPathComponent("NRF")
    }
    
    static func getTempDir() -> URL {
        do{
            if tempDir != nil {
                return tempDir!
            }
            
            // Copy firmware to a temporary directory
            let temp = NSTemporaryDirectory() + "OpenHaystack"
            tempDir = URL(fileURLWithPath: temp)
            
            // try? FileManager.default.removeItem(at: tempDir!)
            
            if FileManager.default.fileExists(atPath: temp) {
                let contents = try FileManager.default.contentsOfDirectory(at: tempDir!, includingPropertiesForKeys: nil, options: [])
                
                for fileURL in contents {
                    if fileURL.lastPathComponent != "venv" {
                        try FileManager.default.removeItem(at: fileURL)
                        print("Deleted: \(fileURL.lastPathComponent)")
                    }
                }
            }
            
            try? FileManager.default.createDirectory(atPath: temp, withIntermediateDirectories: false, attributes: nil)
            
            guard let nrfDirectory = nrfFirmwareDirectory else { return tempDir! }
            
            try FileManager.default.copyFolder(from: nrfDirectory, to: tempDir!)
            
            return tempDir!
        }
        catch
        {
            return tempDir!
        }
    }

    /// Runs the script to flash the firmware onto an nRF Device.
    static func flashToNRF(accessory: Accessory, completion: @escaping (ClosureResult) -> Void) throws {
        let urlTemp = getTempDir()
        print(urlTemp)
        
        let urlScript = urlTemp.appendingPathComponent("flash_nrf_lp.sh")
        try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: urlScript.path)
        try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: urlTemp.appendingPathComponent("flash_nrf_lp.py").path)
        try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: urlTemp.appendingPathComponent("check_nrf.py").path)

        // Get public key, newest relevant symmetric key and updateInterval for flashing
        let advertisementKey = try accessory.getAdvertisementKey()
        let arguments = [advertisementKey.base64EncodedString()]

        // Create file for logging and get file handle
        let loggingFileUrl = urlTemp.appendingPathComponent("nrf_installer.log")
        try "".write(to: loggingFileUrl, atomically: true, encoding: .utf8)
        let loggingFileHandle = FileHandle.init(forWritingAtPath: loggingFileUrl.path)!

        print(loggingFileUrl)
        
        // Run script
        let task = try NSUserUnixTask(url: urlScript)
        task.standardOutput = loggingFileHandle
        task.standardError = loggingFileHandle
        task.execute(withArguments: arguments) { e in
            DispatchQueue.main.async {
                if let error = e {
                    completion(.failure(loggingFileUrl, error))
                } else {
                    completion(.success(loggingFileUrl))
                }
            }
        }

        try loggingFileHandle.close()
    }
    
    static func checkDeviceConnection(completion: @escaping (ClosureResult) -> Void) throws {
        let urlTemp = getTempDir()

        let urlScript = urlTemp.appendingPathComponent("check_nrf.sh")
        try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: urlScript.path)
        try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o755], ofItemAtPath: urlTemp.appendingPathComponent("check_nrf.py").path)

        // Create file for logging and get file handle
        let loggingFileUrl = urlTemp.appendingPathComponent("nrf_checker.log")
        try "".write(to: loggingFileUrl, atomically: true, encoding: .utf8)
        let loggingFileHandle = FileHandle.init(forWritingAtPath: loggingFileUrl.path)!

        // Run script
        let task = try NSUserUnixTask(url: urlScript)
        task.standardOutput = loggingFileHandle
        task.standardError = loggingFileHandle
        task.execute() { e in
            DispatchQueue.main.async {
                if let error = e {
                    completion(.failure(loggingFileUrl, error))
                } else {
                    completion(.success(loggingFileUrl))
                }
            }
        }

        try loggingFileHandle.close()
    }
}

enum ClosureResult {
    case success(URL)
    case failure(URL, Error)
}

enum NRFFirmwareFlashError: Error {
    /// Missing files for flashing
    case notFound
    /// Flashing / writing failed
    case flashFailed
}
