//
//  File.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//
import UIKit


class IPAddressFetcher {
    // Singleton instance
    static let shared = IPAddressFetcher()

    // Function to fetch the public IP address
    func fetchPublicIP() async throws -> String {
        let url = URL(string: "https://api.ipify.org?format=json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        guard let ipAddress = json?["ip"] as? String else {
            return  "IP Address not found"
        }
        return ipAddress
    }

    // Function to fetch detailed info about the IP address
    func fetchIPDetails(for ipAddress: String) async throws -> IPInfo? {
        let url = URL(string: "https://ipinfo.io/\(ipAddress)/geo")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return IPInfo.parseIPInfo(from: data)
    }
}
