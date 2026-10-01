//
//  StorageService.swift
//  WeatherAppIOS
//

import Foundation
import SwiftData

/// Протокол хранилища данных приложения (избранное и настройки в UserDefaults, кэш погоды в SwiftData)
public protocol StorageServiceProtocol: Sendable {
    // MARK: - UserDefaults
    func loadFavoriteCities() -> [City]
    func saveFavoriteCities(_ cities: [City])
    func loadLastSelectedCityId() -> UUID?
    func saveLastSelectedCityId(_ id: UUID?)
    func loadAppTheme() -> AppTheme
    func saveAppTheme(_ theme: AppTheme)

    // MARK: - SwiftData
    func loadCachedWeather(for cityId: UUID) -> CityWeather?
    func saveCachedWeather(_ weather: CityWeather)
    func loadAllCachedWeather() -> [UUID: CityWeather]
    func saveAllCachedWeather(_ weatherDict: [UUID: CityWeather])
    func deleteCachedWeather(for cityId: UUID)
}

/// Гибридное хранилище
public final class StorageService: StorageServiceProtocol, @unchecked Sendable {
    public static let shared = StorageService()

    private let defaults: UserDefaults
    private let modelContainer: ModelContainer

    private let favoriteCitiesKey = "weather_favorite_cities"
    private let lastSelectedCityIdKey = "weather_last_selected_city_id"
    private let appThemeKey = "weather_app_theme"

    public init(
        defaults: UserDefaults = .standard,
        modelContainer: ModelContainer? = nil
    ) {
        self.defaults = defaults

        if let customContainer = modelContainer {
            self.modelContainer = customContainer
        } else {
            do {
                let schema = Schema([CachedWeatherItem.self])
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Не удалось инициализировать SwiftData ModelContainer: \(error)")
            }
        }
    }

    // MARK: - UserDefaults (Города, настройки, активный экран)

    public func loadFavoriteCities() -> [City] {
        guard let data = defaults.data(forKey: favoriteCitiesKey) else {
            let defaultsCities = City.defaultFavorites
            saveFavoriteCities(defaultsCities)
            return defaultsCities
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([City].self, from: data)
        } catch {
            return City.defaultFavorites
        }
    }

    public func saveFavoriteCities(_ cities: [City]) {
        if let data = try? JSONEncoder().encode(cities) {
            defaults.set(data, forKey: favoriteCitiesKey)
        }
    }

    public func loadLastSelectedCityId() -> UUID? {
        guard let string = defaults.string(forKey: lastSelectedCityIdKey) else { return nil }
        return UUID(uuidString: string)
    }

    public func saveLastSelectedCityId(_ id: UUID?) {
        if let id = id {
            defaults.set(id.uuidString, forKey: lastSelectedCityIdKey)
        } else {
            defaults.removeObject(forKey: lastSelectedCityIdKey)
        }
    }

    public func loadAppTheme() -> AppTheme {
        guard let raw = defaults.string(forKey: appThemeKey),
              let theme = AppTheme(rawValue: raw) else {
            return .system
        }
        return theme
    }

    public func saveAppTheme(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: appThemeKey)
    }

    // MARK: - SwiftData (Кэширование погоды)

    @MainActor
    private var mainContext: ModelContext {
        modelContainer.mainContext
    }

    public func loadCachedWeather(for cityId: UUID) -> CityWeather? {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<CachedWeatherItem> { item in
            item.cityId == cityId
        }
        var descriptor = FetchDescriptor<CachedWeatherItem>(predicate: predicate)
        descriptor.fetchLimit = 1

        guard let cachedItem = try? context.fetch(descriptor).first else {
            return nil
        }

        return cachedItem.toCityWeather()
    }

    public func saveCachedWeather(_ weather: CityWeather) {
        let context = ModelContext(modelContainer)
        let cityId = weather.city.id
        let predicate = #Predicate<CachedWeatherItem> { item in
            item.cityId == cityId
        }
        var descriptor = FetchDescriptor<CachedWeatherItem>(predicate: predicate)
        descriptor.fetchLimit = 1

        let encodedData = (try? JSONEncoder().encode(weather)) ?? Data()

        do {
            if let existing = try context.fetch(descriptor).first {
                existing.cityName = weather.city.name
                existing.weatherData = encodedData
                existing.cachedAt = Date()
            } else {
                let newItem = CachedWeatherItem(
                    cityId: cityId,
                    cityName: weather.city.name,
                    weatherData: encodedData,
                    cachedAt: Date()
                )
                context.insert(newItem)
            }
            try context.save()
        } catch {
            print("Ошибка сохранения погоды в SwiftData: \(error)")
        }
    }

    public func loadAllCachedWeather() -> [UUID: CityWeather] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedWeatherItem>()

        guard let items = try? context.fetch(descriptor) else {
            return [:]
        }

        var result: [UUID: CityWeather] = [:]
        for item in items {
            if let weather = item.toCityWeather() {
                result[item.cityId] = weather
            }
        }
        return result
    }

    public func saveAllCachedWeather(_ weatherDict: [UUID: CityWeather]) {
        for (_, weather) in weatherDict {
            saveCachedWeather(weather)
        }
    }

    public func deleteCachedWeather(for cityId: UUID) {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<CachedWeatherItem> { item in
            item.cityId == cityId
        }
        var descriptor = FetchDescriptor<CachedWeatherItem>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
            try? context.save()
        }
    }
}
