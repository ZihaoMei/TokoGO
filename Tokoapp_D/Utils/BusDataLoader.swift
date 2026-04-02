//
//  BusDataLoader.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/10.
//

import Foundation

class BusDataLoader {
    static func loadRoutes() -> [BusRoute] {
        guard let url = Bundle.main.url(forResource: "busRoutes", withExtension: "json") else {
            print("❌ busRoutes.json not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(BusRoutesData.self, from: data)
            return decoded.routes
        } catch {
            print("❌ Failed to decode JSON: \(error)")
            return []
        }
    }
}
