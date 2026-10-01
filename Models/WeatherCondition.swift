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

    /// Спокойные минималистичные оттенки для фона (сдержанный мягкий градиент)
    public var backgroundColors: [Color] {
        switch self {
        case .clearDay:
            return [Color(white: 0.18), Color(white: 0.12)]
        case .clearNight:
            return [Color(white: 0.12), Color(white: 0.07)]
        case .partlyCloudyDay:
            return [Color(white: 0.20), Color(white: 0.13)]
        case .partlyCloudyNight:
            return [Color(white: 0.13), Color(white: 0.08)]
        case .cloudy, .overcast, .fog:
            return [Color(white: 0.22), Color(white: 0.14)]
        case .drizzle, .rain, .heavyRain:
            return [Color(red: 0.12, green: 0.16, blue: 0.22), Color(white: 0.10)]
        case .thunderstorm:
            return [Color(red: 0.14, green: 0.14, blue: 0.20), Color(white: 0.08)]
        case .snow, .sleet:
            return [Color(red: 0.16, green: 0.20, blue: 0.24), Color(white: 0.11)]
        case .windy:
            return [Color(white: 0.19), Color(white: 0.12)]
        }
    }
}
