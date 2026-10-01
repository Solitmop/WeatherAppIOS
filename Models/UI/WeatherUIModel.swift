//
//  WeatherUIModel.swift
//  WeatherAppIOS
//

import SwiftUI

/// Вспомогательные структуры и утилиты для форматирования и презентации погоды в UI
public enum WeatherUIHelper {
    /// Цвет для значения УФ-индекса
    public static func uvIndexColor(for index: Int) -> Color {
        switch index {
        case 0...2:
            return .green
        case 3...5:
            return .yellow
        case 6...7:
            return .orange
        case 8...10:
            return .red
        default:
            return .purple
        }
    }

    /// Градиент для полосы температурного диапазона
    public static func temperatureBarGradient(min: Double, max: Double) -> LinearGradient {
        LinearGradient(
            colors: [
                colorForTemperature(min),
                colorForTemperature(max)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Цвет для конкретной температуры
    public static func colorForTemperature(_ temp: Double) -> Color {
        switch temp {
        case ..<(-15):
            return Color(red: 0.4, green: 0.6, blue: 0.95)
        case -15..<0:
            return Color(red: 0.2, green: 0.7, blue: 0.9)
        case 0..<10:
            return Color(red: 0.3, green: 0.8, blue: 0.7)
        case 10..<20:
            return Color(red: 0.9, green: 0.8, blue: 0.2)
        case 20..<30:
            return Color(red: 0.95, green: 0.55, blue: 0.1)
        default:
            return Color(red: 0.95, green: 0.25, blue: 0.15)
        }
    }

    /// Угол поворота компаса для направления ветра
    public static func windDirectionDegrees(for direction: String) -> Double {
        switch direction.uppercased() {
        case "С", "N": return 0
        case "СВ", "NE": return 45
        case "В", "E": return 90
        case "ЮВ", "SE": return 135
        case "Ю", "S": return 180
        case "ЮЗ", "SW": return 225
        case "З", "W": return 270
        case "СЗ", "NW": return 315
        default: return 0
        }
    }

    /// Форматирование времени восхода/заката
    public static func formatTime(_ date: Date, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }
}
