//
//  WeatherViewModel.swift
//  WeatherAppIOS
//

import Foundation
import Observation
import CoreLocation

/// Главная ViewModel экрана детальной погоды выбранного города
@Observable
@MainActor
public final class WeatherViewModel {
    public var selectedCity: City
    public var currentWeather: CityWeather?
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var errorMessage: String?

    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationServiceProtocol
    private let storageService: StorageServiceProtocol

    public init(
        initialCity: City = .moscow,
        weatherService: WeatherServiceProtocol = MockWeatherService(),
        locationService: LocationServiceProtocol = LocationService.shared,
        storageService: StorageServiceProtocol = StorageService.shared
    ) {
        self.selectedCity = initialCity
        self.weatherService = weatherService
        self.locationService = locationService
        self.storageService = storageService

        // Проверяем, был ли сохранен последний выбранный город
        if let lastId = storageService.loadLastSelectedCityId(),
           let saved = storageService.loadFavoriteCities().first(where: { $0.id == lastId }) {
            self.selectedCity = saved
        }
    }

    /// Загрузка погоды для выбранного города
    public func loadWeather() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let weather = try await weatherService.fetchWeather(for: selectedCity)
            self.currentWeather = weather
            self.storageService.saveLastSelectedCityId(selectedCity.id)
        } catch {
            self.errorMessage = error.localizedDescription
        }

        self.isLoading = false
    }

    /// Обновление погоды (pull-to-refresh)
    public func refresh() async {
        isRefreshing = true
        do {
            let weather = try await weatherService.fetchWeather(for: selectedCity)
            self.currentWeather = weather
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isRefreshing = false
    }

    /// Смена активного города (например, по клику в списке городов)
    public func selectCity(_ city: City) async {
        guard city.id != selectedCity.id || currentWeather == nil else { return }
        self.selectedCity = city
        self.storageService.saveLastSelectedCityId(city.id)
        await loadWeather()
    }

    /// Запрос геолокации и загрузка погоды по текущему местоположению
    public func loadCurrentLocationWeather() async {
        isLoading = true
        errorMessage = nil

        do {
            let coords = try await locationService.requestCurrentCoordinates()
            let weather = try await weatherService.fetchWeatherForCoordinates(
                latitude: coords.latitude,
                longitude: coords.longitude
            )
            self.selectedCity = weather.city
            self.currentWeather = weather
        } catch {
            self.errorMessage = "Не удалось получить геопозицию: \(error.localizedDescription)"
        }

        self.isLoading = false
    }
}
