//
//  WeatherCondition.swift
//  WeatherAppIOS
//

import SwiftUI

/// Погодные условия с поддержкой минималистичных цветов и иконок SF Symbols
public enum WeatherCondition: String, Codable, CaseIterable, Sendable {
    case clearDay
    case clearNight
    case partlyCloudyDay
    case partlyCloudyNight
    case cloudy
    case overcast
    case drizzle
    case rain
    case heavyRain
    case thunderstorm
    case snow
    case sleet
    case fog
    case windy

    /// Человекочитаемое описание на русском языке
    public var descriptionRu: String {
        switch self {
        case .clearDay, .clearNight:
            return "Ясно"
        case .partlyCloudyDay:
            return "Переменная облачность"
        case .partlyCloudyNight:
            return "Местами облачно"
        case .cloudy:
            return "Облачно"
        case .overcast:
            return "Пасмурно"
        case .drizzle:
            return "Моросящий дождь"
        case .rain:
            return "Дождь"
        case .heavyRain:
            return "Ливень"
        case .thunderstorm:
            return "Гроза"
        case .snow:
            return "Снегопад"
        case .sleet:
            return "Мокрый снег"
        case .fog:
            return "Туман"
        case .windy:
            return "Ветрено"
        }
    }

    /// Имя SF Symbol
    public var sfSymbolName: String {
        switch self {
        case .clearDay:
            return "sun.max.fill"
        case .clearNight:
            return "moon.stars.fill"
        case .partlyCloudyDay:
            return "cloud.sun.fill"
        case .partlyCloudyNight:
            return "cloud.moon.fill"
        case .cloudy:
            return "cloud.fill"
        case .overcast:
            return "smoke.fill"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .snow:
            return "snowflake"
        case .sleet:
            return "cloud.sleet.fill"
        case .fog:
            return "cloud.fog.fill"
        case .windy:
            return "wind"
        }
    }

    /// Цвет иконки в минималистичной палитре
    public var iconColor: Color {
        switch self {
        case .clearDay:
            return .orange
        case .clearNight:
            return .indigo
        case .partlyCloudyDay:
            return .orange.opacity(0.9)
        case .partlyCloudyNight:
            return .indigo.opacity(0.9)
        case .cloudy, .overcast, .fog:
            return .secondary
        case .drizzle, .rain, .heavyRain, .sleet:
            return .blue
        case .thunderstorm:
            return .yellow
        case .snow:
            return .cyan
        case .windy:
            return .teal
        }
    }

    /// Спокойные минималистичные оттенки для фона с адаптацией под цветовую тему
    public func backgroundColors(for colorScheme: ColorScheme) -> [Color] {
        if colorScheme == .dark {
            switch self {
            case .clearDay:
                return [Color(red: 0.13, green: 0.17, blue: 0.24), Color(red: 0.08, green: 0.10, blue: 0.15)]
            case .clearNight:
                return [Color(red: 0.08, green: 0.10, blue: 0.18), Color(red: 0.05, green: 0.06, blue: 0.11)]
            case .partlyCloudyDay:
                return [Color(red: 0.14, green: 0.17, blue: 0.22), Color(red: 0.09, green: 0.11, blue: 0.15)]
            case .partlyCloudyNight:
                return [Color(red: 0.10, green: 0.11, blue: 0.18), Color(red: 0.06, green: 0.07, blue: 0.12)]
            case .cloudy, .overcast, .fog:
                return [Color(white: 0.16), Color(white: 0.10)]
            case .drizzle, .rain, .heavyRain:
                return [Color(red: 0.11, green: 0.15, blue: 0.22), Color(red: 0.07, green: 0.09, blue: 0.14)]
            case .thunderstorm:
                return [Color(red: 0.14, green: 0.13, blue: 0.20), Color(red: 0.08, green: 0.07, blue: 0.13)]
            case .snow, .sleet:
                return [Color(red: 0.13, green: 0.17, blue: 0.21), Color(red: 0.08, green: 0.11, blue: 0.14)]
            case .windy:
                return [Color(red: 0.12, green: 0.16, blue: 0.19), Color(red: 0.08, green: 0.10, blue: 0.13)]
            }
        } else {
            // Светлая тема: чистые, светлые, воздушные оттенки с высокой контрастностью текста
            switch self {
            case .clearDay:
                return [Color(red: 0.88, green: 0.94, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0)]
            case .clearNight:
                return [Color(red: 0.90, green: 0.92, blue: 0.97), Color(red: 0.95, green: 0.95, blue: 0.98)]
            case .partlyCloudyDay:
                return [Color(red: 0.90, green: 0.94, blue: 0.98), Color(red: 0.95, green: 0.97, blue: 0.99)]
            case .partlyCloudyNight:
                return [Color(red: 0.91, green: 0.92, blue: 0.97), Color(red: 0.95, green: 0.96, blue: 0.98)]
            case .cloudy, .overcast, .fog:
                return [Color(red: 0.91, green: 0.93, blue: 0.95), Color(red: 0.95, green: 0.96, blue: 0.98)]
            case .drizzle, .rain, .heavyRain:
                return [Color(red: 0.88, green: 0.92, blue: 0.96), Color(red: 0.94, green: 0.96, blue: 0.98)]
            case .thunderstorm:
                return [Color(red: 0.89, green: 0.90, blue: 0.96), Color(red: 0.94, green: 0.95, blue: 0.98)]
            case .snow, .sleet:
                return [Color(red: 0.91, green: 0.95, blue: 0.99), Color(red: 0.96, green: 0.98, blue: 1.0)]
            case .windy:
                return [Color(red: 0.90, green: 0.94, blue: 0.96), Color(red: 0.95, green: 0.97, blue: 0.98)]
            }
        }
    }
}
