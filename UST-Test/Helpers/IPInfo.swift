//
//  IPDetails.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import Foundation

public class IPInfo: Decodable {
    let timezone: String
    let postal: String
    let region: String
    let ip: String
    let readme: URL
    let org: String
    let hostname: String
    let loc: String
    let city: String
    let country: String
    
    static func parseIPInfo(from jsonData: Data) -> IPInfo? {
        do {
            // Decode the JSON into the IPInfo class
            let ipInfo = try JSONDecoder().decode(IPInfo.self, from: jsonData)
            return ipInfo
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}
