//
//  CachedWeatherItem.swift
//  WeatherAppIOS
//

import Foundation
import SwiftData

/// Модель SwiftData для постоянного хранения кэша погоды на диске
@Model
public final class CachedWeatherItem {
    @Attribute(.unique) public var cityId: UUID
    public var cityName: String
    public var weatherData: Data
    public var cachedAt: Date

    public init(
        cityId: UUID,
        cityName: String,
        weatherData: Data,
        cachedAt: Date = Date()
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.weatherData = weatherData
        self.cachedAt = cachedAt
    }

    /// Удобный инициализатор из агрегата CityWeather
    public convenience init(weather: CityWeather, cachedAt: Date = Date()) {
        let encoded = (try? JSONEncoder().encode(weather)) ?? Data()
        self.init(
            cityId: weather.city.id,
            cityName: weather.city.name,
            weatherData: encoded,
            cachedAt: cachedAt
        )
    }

    /// Восстановление агрегата CityWeather из сохраненных бинарных данных
    public func toCityWeather() -> CityWeather? {
        try? JSONDecoder().decode(CityWeather.self, from: weatherData)
    }
}
