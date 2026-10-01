//
//  WeatherModels.swift
//  WeatherAppIOS
//

import Foundation

/// Текущие показатели погоды
public struct CurrentWeather: Codable, Equatable, Sendable {
    public var temperature: Double         // В градусах Цельсия
    public var feelsLike: Double           // В градусах Цельсия
    public var condition: WeatherCondition
    public var highTemperature: Double     // Дневной максимум
    public var lowTemperature: Double      // Дневной минимум
    public var updatedAt: Date

    public init(
        temperature: Double,
        feelsLike: Double,
        condition: WeatherCondition,
        highTemperature: Double,
        lowTemperature: Double,
        updatedAt: Date = Date()
    ) {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.condition = condition
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.updatedAt = updatedAt
    }
}

/// Почасовой прогноз погоды
public struct HourlyForecast: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var date: Date
    public var temperature: Double
    public var condition: WeatherCondition
    public var precipitationProbability: Int // 0..100 %

    public init(
        id: UUID = UUID(),
        date: Date,
        temperature: Double,
        condition: WeatherCondition,
        precipitationProbability: Int = 0
    ) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.condition = condition
        self.precipitationProbability = precipitationProbability
    }

    /// Форматирование времени для карточки ("Сейчас" или "14:00")
    public func timeString(relativeTo referenceDate: Date = Date(), timeZone: TimeZone = .current) -> String {
        let calendar = Calendar.current
        if calendar.isDate(date, equalTo: referenceDate, toGranularity: .hour) &&
           calendar.isDate(date, inSameDayAs: referenceDate) {
            return "Сейчас"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }
}

/// Суточный прогноз (на день)
public struct DailyForecast: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var date: Date
    public var dayTitle: String            // "Сегодня", "Пн", "Вт", etc.
    public var condition: WeatherCondition
    public var lowTemperature: Double
    public var highTemperature: Double
    public var precipitationProbability: Int

    public init(
        id: UUID = UUID(),
        date: Date,
        dayTitle: String,
        condition: WeatherCondition,
        lowTemperature: Double,
        highTemperature: Double,
        precipitationProbability: Int = 0
    ) {
        self.id = id
        self.date = date
        self.dayTitle = dayTitle
        self.condition = condition
        self.lowTemperature = lowTemperature
        self.highTemperature = highTemperature
        self.precipitationProbability = precipitationProbability
    }
}

/// Дополнительные метеорологические метрики
public struct WeatherMetrics: Codable, Equatable, Sendable {
    public var windSpeedMps: Double         // м/с
    public var windDirection: String        // "СЗ", "ЮВ", etc.
    public var windGustMps: Double?         // Порывы ветра
    public var humidityPercentage: Int      // Влажность %
    public var pressureHpa: Double          // Давление в гПа
    public var uvIndex: Int                 // УФ-индекс (0..12)
    public var visibilityKm: Double         // Видимость в км
    public var dewPointCelsius: Double      // Точка росы
    public var sunrise: Date                // Время восхода
    public var sunset: Date                 // Время заката

    public init(
        windSpeedMps: Double,
        windDirection: String,
        windGustMps: Double? = nil,
        humidityPercentage: Int,
        pressureHpa: Double,
        uvIndex: Int,
        visibilityKm: Double,
        dewPointCelsius: Double,
        sunrise: Date,
        sunset: Date
    ) {
        self.windSpeedMps = windSpeedMps
        self.windDirection = windDirection
        self.windGustMps = windGustMps
        self.humidityPercentage = humidityPercentage
        self.pressureHpa = pressureHpa
        self.uvIndex = uvIndex
        self.visibilityKm = visibilityKm
        self.dewPointCelsius = dewPointCelsius
        self.sunrise = sunrise
        self.sunset = sunset
    }

    /// Текстовое описание уровня УФ-индекса
    public var uvDescription: String {
        switch uvIndex {
        case 0...2:
            return "Низкий уровень. Защита не требуется."
        case 3...5:
            return "Средний. Используйте солнцезащитные очки."
        case 6...7:
            return "Высокий. Необходим SPF крем и тень."
        case 8...10:
            return "Очень высокий. Избегайте полуденного солнца."
        default:
            return "Экстремальный. Оставайтесь в помещении."
        }
    }

    /// Краткий статус УФ
    public var uvShortStatus: String {
        switch uvIndex {
        case 0...2: return "Низкий"
        case 3...5: return "Умеренный"
        case 6...7: return "Высокий"
        case 8...10: return "Очень высокий"
        default: return "Экстремальный"
        }
    }
}

/// Полная сводка погоды по городу (агрегат данных)
public struct CityWeather: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID { city.id }
    public var city: City
    public var current: CurrentWeather
    public var hourly: [HourlyForecast]
    public var daily: [DailyForecast]
    public var metrics: WeatherMetrics

    public init(
        city: City,
        current: CurrentWeather,
        hourly: [HourlyForecast],
        daily: [DailyForecast],
        metrics: WeatherMetrics
    ) {
        self.city = city
        self.current = current
        self.hourly = hourly
        self.daily = daily
        self.metrics = metrics
    }
}
