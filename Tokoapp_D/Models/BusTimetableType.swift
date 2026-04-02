//
//  BusTimetableType.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/10.
//

import Foundation

/// 唯一的时刻表类型枚举
enum BusTimetableType: String, CaseIterable {
    case weekday    // 平日
    case saturday   // 周六
    case holiday    // 周日/假日
    case special   // 特別

    var title: String {
        switch self {
        case .weekday: return "平日"
        case .saturday: return "土曜"
        case .holiday: return "日曜/休日"
        case .special: return "特別"
        }
    }

    /// 根据当天日期返回默认类型
    static func todayType() -> BusTimetableType {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        switch weekday {
        case 1: return .holiday   // Sunday
        case 7: return .saturday  // Saturday
        default:
            // ⚠️ 这里你可以根据校历判断是否休校
            return .weekday
        }
    }
}

