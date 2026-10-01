//
//  City.swift
//  WeatherAppIOS
//

import Foundation

/// Модель города для отображения и поиска
public struct City: Identifiable, Codable, Hashable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var region: String
    public var latitude: Double
    public var longitude: Double
    public var timeZoneIdentifier: String
    public var isCurrentLocation: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        region: String,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String = "Europe/Moscow",
        isCurrentLocation: Bool = false
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
        self.isCurrentLocation = isCurrentLocation
    }

    /// Локальное время в городе
    public var localTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: Date())
    }

    public var subtitle: String {
        if isCurrentLocation {
            return "Текущее местоположение"
        } else {
            return region
        }
    }
}

// MARK: - Российские города
extension City {
    public static let moscow = City(
        name: "Москва",
        region: "Московская область",
        latitude: 55.7558,
        longitude: 37.6173,
        timeZoneIdentifier: "Europe/Moscow",
        isCurrentLocation: true
    )

    public static let saintPetersburg = City(
        name: "Санкт-Петербург",
        region: "Ленинградская область",
        latitude: 59.9343,
        longitude: 30.3351,
        timeZoneIdentifier: "Europe/Moscow"
    )

    public static let kazan = City(
        name: "Казань",
        region: "Республика Татарстан",
        latitude: 55.7887,
        longitude: 49.1221,
        timeZoneIdentifier: "Europe/Moscow"
    )

    public static let yekaterinburg = City(
        name: "Екатеринбург",
        region: "Свердловская область",
        latitude: 56.8389,
        longitude: 60.6057,
        timeZoneIdentifier: "Asia/Yekaterinburg"
    )

    public static let novosibirsk = City(
        name: "Новосибирск",
        region: "Новосибирская область",
        latitude: 55.0084,
        longitude: 82.9357,
        timeZoneIdentifier: "Asia/Novosibirsk"
    )

    public static let sochi = City(
        name: "Сочи",
        region: "Краснодарский край",
        latitude: 43.6028,
        longitude: 39.7342,
        timeZoneIdentifier: "Europe/Moscow"
    )

    public static let nizhnyNovgorod = City(
        name: "Нижний Новгород",
        region: "Нижегородская область",
        latitude: 56.3269,
        longitude: 44.0059,
        timeZoneIdentifier: "Europe/Moscow"
    )

    public static let samara = City(
        name: "Самара",
        region: "Самарская область",
        latitude: 53.1959,
        longitude: 50.1002,
        timeZoneIdentifier: "Europe/Samara"
    )

    public static let vladivostok = City(
        name: "Владивосток",
        region: "Приморский край",
        latitude: 43.1198,
        longitude: 131.8869,
        timeZoneIdentifier: "Asia/Vladivostok"
    )

    public static let kaliningrad = City(
        name: "Калининград",
        region: "Калининградская область",
        latitude: 54.7104,
        longitude: 20.4522,
        timeZoneIdentifier: "Europe/Kaliningrad"
    )

    public static let krasnoyarsk = City(
        name: "Красноярск",
        region: "Красноярский край",
        latitude: 56.0153,
        longitude: 92.8932,
        timeZoneIdentifier: "Asia/Krasnoyarsk"
    )

    /// Список городов по умолчанию для избранного
    public static let defaultFavorites: [City] = [
        .moscow,
        .saintPetersburg,
        .kazan,
        .yekaterinburg,
        .sochi
    ]
}
