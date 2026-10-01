//
//  WeatherViewModel.swift
//  WeatherAppIOS
//

import Foundation
import Observation

/// Главная ViewModel экрана детальной погоды выбранного города
@Observable
@MainActor
public final class WeatherViewModel {
    public var selectedCity: City
    public var currentWeather: CityWeather?
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var isFromCache: Bool = false
    public var errorMessage: String?
    public var showNoInternetToast: Bool = false

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
    private let storageService: StorageServiceProtocol
    private let networkMonitor: NetworkMonitor
    private var toastDismissTask: Task<Void, Never>?

    public init(
        initialCity: City = .moscow,
        weatherService: WeatherServiceProtocol = MockWeatherService(),
        storageService: StorageServiceProtocol = StorageService.shared,
        networkMonitor: NetworkMonitor = NetworkMonitor.shared
    ) {
        self.selectedCity = initialCity
        self.weatherService = weatherService
        self.storageService = storageService
        self.networkMonitor = networkMonitor

        // Проверяем сохраненный последний выбранный город
        if let lastId = storageService.loadLastSelectedCityId(),
           let saved = storageService.loadFavoriteCities().first(where: { $0.id == lastId }) {
            self.selectedCity = saved
        }

        // Загружаем кэш для мгновенного отображения при запуске
        if let cached = storageService.loadCachedWeather(for: self.selectedCity.id) {
            self.currentWeather = cached
            self.isFromCache = true
        }
    }

    /// Загрузка погоды для выбранного города
    public func loadWeather() async {
        guard !isLoading else { return }
        isLoading = true

        // Если в памяти еще нет данных, поднимаем из дискового кэша
        if currentWeather == nil, let cached = storageService.loadCachedWeather(for: selectedCity.id) {
            self.currentWeather = cached
            self.isFromCache = true
        }

        // Проверка подключения к интернету
        if !networkMonitor.isConnected {
            triggerNoInternetNotification()
            self.isLoading = false
            return
        }

        do {
            let weather = try await weatherService.fetchWeather(for: selectedCity)
            self.currentWeather = weather
            self.isFromCache = false
            self.errorMessage = nil

            // Сохранение в кэш сразу после получения данных
            storageService.saveCachedWeather(weather)
            storageService.saveLastSelectedCityId(selectedCity.id)
        } catch {
            triggerNoInternetNotification()
            if self.currentWeather != nil {
                self.isFromCache = true
            } else {
                self.errorMessage = error.localizedDescription
            }
        }

        self.isLoading = false
    }

    /// Обновление погоды (pull-to-refresh)
    public func refresh() async {
        isRefreshing = true

        if !networkMonitor.isConnected {
            triggerNoInternetNotification()
            self.isRefreshing = false
            return
        }

        do {
            let weather = try await weatherService.fetchWeather(for: selectedCity)
            self.currentWeather = weather
            self.isFromCache = false
            self.errorMessage = nil

            storageService.saveCachedWeather(weather)
        } catch {
            triggerNoInternetNotification()
            if self.currentWeather != nil {
                self.isFromCache = true
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
        self.isRefreshing = false
    }

    /// Смена активного города
    public func selectCity(_ city: City) async {
        guard city.id != selectedCity.id || currentWeather == nil else { return }
        self.selectedCity = city
        self.storageService.saveLastSelectedCityId(city.id)

        // Мгновенно отображаем кэш для выбранного города
        if let cached = storageService.loadCachedWeather(for: city.id) {
            self.currentWeather = cached
            self.isFromCache = true
        }

        await loadWeather()
    }

    /// Сохранение текущего состояния погоды перед сворачиванием / уходом в спящий режим
    public func saveStateBeforeSleep() {
        if let current = currentWeather {
            storageService.saveCachedWeather(current)
        }
        storageService.saveLastSelectedCityId(selectedCity.id)
    }

    /// Вызов всплывающего уведомления об отсутствии интернета с автоскрытием
    public func triggerNoInternetNotification() {
        showNoInternetToast = true
        toastDismissTask?.cancel()
        toastDismissTask = Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            guard !Task.isCancelled else { return }
            self.showNoInternetToast = false
        }
    }

    public func dismissNoInternetNotification() {
        toastDismissTask?.cancel()
        showNoInternetToast = false
    }
}
