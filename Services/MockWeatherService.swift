//
//  MockWeatherService.swift
//  WeatherAppIOS
//

import Foundation

/// Мок-сервис с данными городов России
public final class MockWeatherService: WeatherServiceProtocol {

    public init() {}

    /// Каталог доступных городов
    public var availableCities: [City] = [
        .moscow,
        .saintPetersburg,
        .kazan,
        .yekaterinburg,
        .novosibirsk,
        .sochi,
        .nizhnyNovgorod,
        .samara,
        .vladivostok,
        .kaliningrad,
        .krasnoyarsk,
        City(name: "Ростов-на-Дону", region: "Ростовская область", latitude: 47.2357, longitude: 39.7015),
        City(name: "Уфа", region: "Республика Башкортостан", latitude: 54.7388, longitude: 55.9721, timeZoneIdentifier: "Asia/Yekaterinburg"),
        City(name: "Челябинск", region: "Челябинская область", latitude: 55.1644, longitude: 61.4368, timeZoneIdentifier: "Asia/Yekaterinburg"),
        City(name: "Омск", region: "Омская область", latitude: 54.9885, longitude: 73.3242, timeZoneIdentifier: "Asia/Omsk"),
        City(name: "Воронеж", region: "Воронежская область", latitude: 51.6615, longitude: 39.2003),
        City(name: "Пермь", region: "Пермский край", latitude: 58.0105, longitude: 56.2502, timeZoneIdentifier: "Asia/Yekaterinburg"),
        City(name: "Краснодар", region: "Краснодарский край", latitude: 45.0355, longitude: 38.9753)
    ]

    public func fetchWeather(for city: City) async throws -> CityWeather {
        try? await Task.sleep(nanoseconds: 100_000_000)

        let baseTemp: Double
        let condition: WeatherCondition
        let feelsDelta: Double
        let windSpeedMps: Double
        let windDir: String
        let humidity: Int
        let pressureHpa: Double
        let uv: Int

        switch city.name {
        case "Москва":
            baseTemp = 11.0
            condition = .partlyCloudyDay
            feelsDelta = -1.5
            windSpeedMps = 3.8
            windDir = "ЮЗ"
            humidity = 64
            pressureHpa = 1016.0
            uv = 2
        case "Санкт-Петербург":
            baseTemp = 8.0
            condition = .rain
            feelsDelta = -3.0
            windSpeedMps = 5.6
            windDir = "З"
            humidity = 82
            pressureHpa = 1009.0
            uv = 1
        case "Казань":
            baseTemp = 10.0
            condition = .cloudy
            feelsDelta = -1.0
            windSpeedMps = 3.2
            windDir = "Ю"
            humidity = 68
            pressureHpa = 1018.0
            uv = 2
        case "Екатеринбург":
            baseTemp = 7.0
            condition = .partlyCloudyDay
            feelsDelta = -2.0
            windSpeedMps = 4.0
            windDir = "СЗ"
            humidity = 58
            pressureHpa = 1020.0
            uv = 2
        case "Новосибирск":
            baseTemp = 5.0
            condition = .clearDay
            feelsDelta = -1.5
            windSpeedMps = 3.0
            windDir = "В"
            humidity = 55
            pressureHpa = 1024.0
            uv = 2
        case "Сочи":
            baseTemp = 21.0
            condition = .clearDay
            feelsDelta = 1.0
            windSpeedMps = 2.4
            windDir = "Ю"
            humidity = 50
            pressureHpa = 1014.0
            uv = 5
        case "Нижний Новгород":
            baseTemp = 9.0
            condition = .overcast
            feelsDelta = -1.5
            windSpeedMps = 3.5
            windDir = "ЮЗ"
            humidity = 72
            pressureHpa = 1015.0
            uv = 1
        case "Владивосток":
            baseTemp = 7.0
            condition = .windy
            feelsDelta = -4.0
            windSpeedMps = 8.2
            windDir = "С"
            humidity = 60
            pressureHpa = 1022.0
            uv = 2
        case "Калининград":
            baseTemp = 12.0
            condition = .drizzle
            feelsDelta = -1.0
            windSpeedMps = 4.8
            windDir = "З"
            humidity = 80
            pressureHpa = 1011.0
            uv = 1
        default:
            baseTemp = 9.0 + (city.latitude.truncatingRemainder(dividingBy: 5))
            condition = .partlyCloudyDay
            feelsDelta = -1.0
            windSpeedMps = 3.5
            windDir = "СЗ"
            humidity = 65
            pressureHpa = 1015.0
            uv = 2
        }

        let current = CurrentWeather(
            temperature: baseTemp,
            feelsLike: baseTemp + feelsDelta,
            condition: condition,
            highTemperature: baseTemp + 4.0,
            lowTemperature: baseTemp - 5.0,
            updatedAt: Date()
        )

        let hourly = generateHourlyForecast(baseTemperature: baseTemp, primaryCondition: condition)
        let daily = generateDailyForecast(baseTemperature: baseTemp, primaryCondition: condition)

        let calendar = Calendar.current
        let today = Date()
        let sunrise = calendar.date(bySettingHour: 6, minute: 30, second: 0, of: today) ?? today
        let sunset = calendar.date(bySettingHour: 18, minute: 45, second: 0, of: today) ?? today

        let metrics = WeatherMetrics(
            windSpeedMps: windSpeedMps,
            windDirection: windDir,
            windGustMps: windSpeedMps * 1.4,
            humidityPercentage: humidity,
            pressureHpa: pressureHpa,
            uvIndex: uv,
            visibilityKm: 10.0,
            dewPointCelsius: baseTemp - 5.0,
            sunrise: sunrise,
            sunset: sunset
        )

        return CityWeather(
            city: city,
            current: current,
            hourly: hourly,
            daily: daily,
            metrics: metrics
        )
    }

    public func searchCities(query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return [] }

        return availableCities.filter { city in
            city.name.lowercased().contains(trimmed) ||
            city.region.lowercased().contains(trimmed)
        }
    }

    public func fetchWeatherForCoordinates(latitude: Double, longitude: Double) async throws -> CityWeather {
        let city = City(
            name: "Текущее местоположение",
            region: "Определено по GPS",
            latitude: latitude,
            longitude: longitude,
            isCurrentLocation: true
        )
        return try await fetchWeather(for: city)
    }

    // MARK: - Генерация почасового и суточного прогнозов

    private func generateHourlyForecast(baseTemperature: Double, primaryCondition: WeatherCondition) -> [HourlyForecast] {
        let calendar = Calendar.current
        let now = Date()
        var items: [HourlyForecast] = []

        for offset in 0..<24 {
            guard let date = calendar.date(byAdding: .hour, value: offset, to: now) else { continue }
            let hour = calendar.component(.hour, from: date)
            let variation = sin(Double(hour - 6) * .pi / 12.0) * 3.5
            let temp = baseTemperature + variation

            let isNight = hour < 6 || hour > 21
            let condition: WeatherCondition
            switch primaryCondition {
            case .rain, .heavyRain, .drizzle:
                condition = offset % 3 == 0 ? .rain : .cloudy
            case .snow, .sleet:
                condition = .snow
            case .clearDay, .clearNight:
                condition = isNight ? .clearNight : .clearDay
            default:
                condition = isNight ? .partlyCloudyNight : .partlyCloudyDay
            }

            let precip = (condition == .rain || condition == .snow) ? 60 : 0

            items.append(HourlyForecast(
                date: date,
                temperature: round(temp),
                condition: condition,
                precipitationProbability: precip
            ))
        }

        return items
    }

    private func generateDailyForecast(baseTemperature: Double, primaryCondition: WeatherCondition) -> [DailyForecast] {
        let calendar = Calendar.current
        let now = Date()
        var items: [DailyForecast] = []

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"

        let conditionsPool: [WeatherCondition] = [
            primaryCondition,
            .partlyCloudyDay,
            .clearDay,
            .cloudy,
            .overcast,
            .rain,
            .partlyCloudyDay
        ]

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            let title = dayOffset == 0 ? "Сегодня" : formatter.string(from: date).capitalized

            let condition = conditionsPool[dayOffset % conditionsPool.count]
            let low = baseTemperature - 4.0 + Double(dayOffset % 2)
            let high = baseTemperature + 3.0 + Double(dayOffset % 3)

            let precip = condition == .rain ? 55 : 0

            items.append(DailyForecast(
                date: date,
                dayTitle: title,
                condition: condition,
                lowTemperature: round(low),
                highTemperature: round(high),
                precipitationProbability: precip
            ))
        }

        return items
    }
}
