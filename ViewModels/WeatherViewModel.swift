//
//  WeatherViewModel.swift
//  WeatherAppIOS
//

import Foundation
import Observation
import CoreLocation

/// Главная ViewModel экрана детальной погоды выбранного города с поддержкой офлайн-кэширования
@Observable
@MainActor
public final class WeatherViewModel {
    public var selectedCity: City
    public var currentWeather: CityWeather?
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var isFromCache: Bool = false
    public var errorMessage: String?

    /// Описание давности кэша («5 минут назад», «1 час назад» и т.д.)
    public var cacheAgeDescription: String? {
        guard let updatedAt = currentWeather?.current.updatedAt else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }

    /// Точное время обновления («17:45»)
    public var formattedUpdateTime: String? {
        guard let updatedAt = currentWeather?.current.updatedAt else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: updatedAt)
    }

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

        // Загружаем сохраненный кэш погоды для мгновенного отображения при запуске
        if let cached = storageService.loadCachedWeather(for: self.selectedCity.id) {
            self.currentWeather = cached
            self.isFromCache = true
        }
    }

    /// Загрузка погоды для выбранного города (с поддержкой офлайн-режима)
    public func loadWeather() async {
        guard !isLoading else { return }
        isLoading = true

        // Если данных еще нет в памяти, пробуем подтянуть из дискового кэша
        if currentWeather == nil, let cached = storageService.loadCachedWeather(for: selectedCity.id) {
            self.currentWeather = cached
            self.isFromCache = true
        }

        do {
            let weather = try await weatherService.fetchWeather(for: selectedCity)
            self.currentWeather = weather
            self.isFromCache = false
            self.errorMessage = nil

            // 1. Сохранение сразу после получения актуальных данных
            storageService.saveCachedWeather(weather)
            storageService.saveLastSelectedCityId(selectedCity.id)
        } catch {
            if self.currentWeather != nil {
                // Если данные уже есть (из кэша), остаемся в офлайн-режиме без падения экрана
                self.isFromCache = true
                self.errorMessage = "Офлайн-режим. Показаны сохраненные данные"
            } else {
                self.errorMessage = error.localizedDescription
            }
        }

        self.isLoading = false
    }

    /// Обновление погоды (pull-to-refresh)
    public func refresh() async {
        isRefreshing = true
        do {
            let weather = try await weatherService.fetchWeather(for: selectedCity)
            self.currentWeather = weather
            self.isFromCache = false
            self.errorMessage = nil

            // Сохранение сразу после получения обновленных данных
            storageService.saveCachedWeather(weather)
        } catch {
            if self.currentWeather != nil {
                self.isFromCache = true
                self.errorMessage = "Офлайн-режим: нет подключения к сети"
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
        self.isRefreshing = false
    }

    /// Смена активного города (например, по клику в списке городов)
    public func selectCity(_ city: City) async {
        guard city.id != selectedCity.id || currentWeather == nil else { return }
        self.selectedCity = city
        self.storageService.saveLastSelectedCityId(city.id)

        // Мгновенно отображаем кэш для выбранного города, если он есть
        if let cached = storageService.loadCachedWeather(for: city.id) {
            self.currentWeather = cached
            self.isFromCache = true
        }

        await loadWeather()
    }

    /// Запрос геолокации и загрузка погоды по текущему местоположению
    public func loadCurrentLocationWeather() async {
        isLoading = true

        do {
            let coords = try await locationService.requestCurrentCoordinates()
            let weather = try await weatherService.fetchWeatherForCoordinates(
                latitude: coords.latitude,
                longitude: coords.longitude
            )
            self.selectedCity = weather.city
            self.currentWeather = weather
            self.isFromCache = false
            self.errorMessage = nil

            // Сохранение сразу после получения
            storageService.saveCachedWeather(weather)
        } catch {
            self.errorMessage = "Не удалось получить геопозицию: \(error.localizedDescription)"
        }

        self.isLoading = false
    }

    // MARK: - Сохранение перед уходом в спящий режим

    /// Сохранение текущего состояния погоды перед сворачиванием / уходом в спящий режим
    public func saveStateBeforeSleep() {
        if let current = currentWeather {
            storageService.saveCachedWeather(current)
        }
        storageService.saveLastSelectedCityId(selectedCity.id)
    }
}
