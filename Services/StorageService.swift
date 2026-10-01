//
//  StorageService.swift
//  WeatherAppIOS
//

import Foundation

/// Протокол хранилища данных приложения
public protocol StorageServiceProtocol: Sendable {
    func loadFavoriteCities() -> [City]
    func saveFavoriteCities(_ cities: [City])
    func loadLastSelectedCityId() -> UUID?
    func saveLastSelectedCityId(_ id: UUID?)
    func loadAppTheme() -> AppTheme
    func saveAppTheme(_ theme: AppTheme)
}

/// Упрощенное хранилище на базе UserDefaults
public final class StorageService: StorageServiceProtocol, @unchecked Sendable {
    public static let shared = StorageService()

    private let defaults: UserDefaults
    private let favoriteCitiesKey = "weather_favorite_cities"
    private let lastSelectedCityIdKey = "weather_last_selected_city_id"
    private let appThemeKey = "weather_app_theme"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

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
}
