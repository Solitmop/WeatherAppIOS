//
//  AppSettings.swift
//  WeatherAppIOS
//

import SwiftUI

/// Единицы измерения Международной системы единиц (СИ)
public enum MetricFormatter {
    /// Форматирование температуры в градусах Цельсия (°C)
    public static func temperature(_ celsius: Double, showSign: Bool = true) -> String {
        let value = Int(round(celsius))
        if showSign && value > 0 {
            return "+\(value)°"
        } else {
            return "\(value)°"
        }
    }

    /// Форматирование скорости ветра в метрах в секунду (м/с — единица СИ)
    public static func windSpeed(_ mps: Double) -> String {
        String(format: "%.1f м/с", mps)
    }

    /// Форматирование давления в гектопаскалях (гПа — единица СИ, 1 гПа = 100 Па)
    public static func pressure(_ hPa: Double) -> String {
        "\(Int(round(hPa))) гПа"
    }

    /// Форматирование видимости в километрах
    public static func visibility(_ km: Double) -> String {
        "\(Int(round(km))) км"
    }
}

/// Тема оформления интерфейса
public enum AppTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case dark = "dark"
    case light = "light"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system:
            return "Системная"
        case .dark:
            return "Тёмная"
        case .light:
            return "Светлая"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
}
