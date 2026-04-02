//
//  BusRoute.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/10.
//

import Foundation

struct BusRoutesData: Codable {
    let routes: [BusRoute]
}

struct BusRoute: Codable {
    let name: String
    let departureLocation: String
    let timetables: [String: [String]] // weekday, noschool, saturday, holiday
}
