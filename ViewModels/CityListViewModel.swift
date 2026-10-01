//
//  CityListViewModel.swift
//  WeatherAppIOS
//

import Foundation
import Observation

/// ViewModel для управления списком избранных городов и поиска новых локаций
@Observable
@MainActor
public final class CityListViewModel {
    public var savedCities: [City] = []
    public var savedCitiesWeather: [CityWeather] = []
    public var searchQuery: String = "" {
        didSet {
            searchCities()
        }
    }
    public var searchResults: [City] = []
    public var isSearching: Bool = false
    public var isLoading: Bool = false
    public var errorMessage: String?

    private let weatherService: WeatherServiceProtocol
    private let storageService: StorageServiceProtocol
    private var searchTask: Task<Void, Never>?

    public init(
        weatherService: WeatherServiceProtocol = MockWeatherService(),
        storageService: StorageServiceProtocol = StorageService.shared
    ) {
        self.weatherService = weatherService
        self.storageService = storageService
        self.savedCities = storageService.loadFavoriteCities()
    }

    /// Загрузка погоды для всех сохраненных городов
    public func loadSavedCitiesWeather() async {
        isLoading = true
        errorMessage = nil

        var updatedList: [CityWeather] = []

        for city in savedCities {
            do {
                let weather = try await weatherService.fetchWeather(for: city)
                updatedList.append(weather)
            } catch {
                print("Failed to fetch weather for \(city.name): \(error)")
            }
        }

        self.savedCitiesWeather = updatedList
        self.isLoading = false
    }

    /// Поиск городов с дебаунсом 300мс
    public func searchCities() {
        searchTask?.cancel()

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            self.searchResults = []
            self.isSearching = false
            return
        }

        self.isSearching = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            do {
                let results = try await weatherService.searchCities(query: query)
                guard !Task.isCancelled else { return }
                self.searchResults = results
                self.isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                self.searchResults = []
                self.isSearching = false
            }
        }
    }

    /// Добавление города в избранное
    public func addCity(_ city: City) async {
        guard !savedCities.contains(where: { $0.name == city.name && $0.region == city.region }) else {
            return
        }

        var newCity = city
        newCity.isCurrentLocation = false
        savedCities.append(newCity)
        storageService.saveFavoriteCities(savedCities)

        // Подгружаем сводку погоды для добавленного города
        if let weather = try? await weatherService.fetchWeather(for: newCity) {
            savedCitiesWeather.append(weather)
        }
    }

    /// Удаление города из избранного по индексу
    public func deleteCity(at offsets: IndexSet) {
        // Запрещаем удаление текущей геопозиции, если она первая
        let citiesToDelete = offsets.map { savedCities[$0] }
        for city in citiesToDelete where !city.isCurrentLocation {
            savedCities.removeAll { $0.id == city.id }
            savedCitiesWeather.removeAll { $0.city.id == city.id }
        }
        storageService.saveFavoriteCities(savedCities)
    }

    /// Удаление конкретного города
    public func deleteCity(_ city: City) {
        guard !city.isCurrentLocation else { return }
        savedCities.removeAll { $0.id == city.id }
        savedCitiesWeather.removeAll { $0.city.id == city.id }
        storageService.saveFavoriteCities(savedCities)
    }

    /// Проверка, добавлен ли уже город в список избранных
    public func isCitySaved(_ city: City) -> Bool {
        savedCities.contains(where: { $0.name == city.name && $0.region == city.region })
    }
}
