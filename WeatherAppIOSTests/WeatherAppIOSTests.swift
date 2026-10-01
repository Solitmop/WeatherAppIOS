//
//  WeatherAppIOSTests.swift
//  WeatherAppIOSTests
//

import Testing
import Foundation
import SwiftData
@testable import WeatherAppIOS

struct WeatherAppIOSTests {

    @Test func testMockWeatherServiceReturnsRussianCityData() async throws {
        let service = MockWeatherService()
        let city = City.moscow

        let weather = try await service.fetchWeather(for: city)

        #expect(weather.city.name == "Москва")
        #expect(weather.hourly.count == 24)
        #expect(weather.daily.count == 7)
        #expect(weather.metrics.humidityPercentage >= 0 && weather.metrics.humidityPercentage <= 100)
        #expect(weather.metrics.pressureHpa > 900)
    }

    @Test func testRussianCitiesSearch() async throws {
        let service = MockWeatherService()

        let spbResults = try await service.searchCities(query: "Санкт")
        #expect(!spbResults.isEmpty)
        #expect(spbResults.contains(where: { $0.name == "Санкт-Петербург" }))

        let kazanResults = try await service.searchCities(query: "Казань")
        #expect(!kazanResults.isEmpty)
        #expect(kazanResults.first?.region == "Республика Татарстан")

        let empty = try await service.searchCities(query: "NewYorkCity")
        #expect(empty.isEmpty)
    }

    @Test func testSIMetricFormatter() {
        // Температура (°C)
        #expect(MetricFormatter.temperature(15) == "+15°")
        #expect(MetricFormatter.temperature(-5) == "-5°")
        #expect(MetricFormatter.temperature(0) == "0°")
        #expect(MetricFormatter.temperature(20, showSign: false) == "20°")

        // Ветер (м/с)
        #expect(MetricFormatter.windSpeed(4.5) == "4.5 м/с")

        // Давление (гПа)
        #expect(MetricFormatter.pressure(1016.4) == "1016 гПа")

        // Видимость (км)
        #expect(MetricFormatter.visibility(10.0) == "10 км")
    }

    @Test @MainActor func testCityListViewModelAddAndDelete() async {
        let service = MockWeatherService()
        let vm = CityListViewModel(weatherService: service)

        let samara = City(name: "Самара", region: "Самарская область", latitude: 53.19, longitude: 50.10)

        await vm.addCity(samara)
        #expect(vm.isCitySaved(samara))

        // Дубликат не должен повторно добавляться
        await vm.addCity(samara)
        #expect(vm.savedCities.filter { $0.name == "Самара" }.count == 1)

        vm.deleteCity(samara)
        #expect(!vm.isCitySaved(samara))
    }

    @Test func testWeatherConditionBackgroundColors() {
        let condition = WeatherCondition.clearDay
        let lightColors = condition.backgroundColors(for: .light)
        let darkColors = condition.backgroundColors(for: .dark)

        #expect(!lightColors.isEmpty)
        #expect(!darkColors.isEmpty)
        #expect(lightColors != darkColors)
    }

    @Test func testSwiftDataWeatherCaching() async throws {
        let schema = Schema([CachedWeatherItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])

        let storage = StorageService(defaults: .standard, modelContainer: container)
        let service = MockWeatherService()
        let weather = try await service.fetchWeather(for: .moscow)

        storage.saveCachedWeather(weather)

        let cached = storage.loadCachedWeather(for: weather.city.id)
        #expect(cached != nil)
        #expect(cached?.city.name == "Москва")
        #expect(cached?.current.temperature == weather.current.temperature)
    }

    @Test @MainActor func testWeatherViewModelSavesBeforeSleepWithSwiftData() async throws {
        let schema = Schema([CachedWeatherItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])

        let storage = StorageService(defaults: .standard, modelContainer: container)
        let weatherService = MockWeatherService()

        let vm = WeatherViewModel(
            initialCity: .kazan,
            weatherService: weatherService,
            storageService: storage
        )

        await vm.loadWeather()
        #expect(vm.currentWeather != nil)

        // Имитируем вызов сохранения перед уходом в сон
        vm.saveStateBeforeSleep()

        let cached = storage.loadCachedWeather(for: City.kazan.id)
        #expect(cached != nil)
        #expect(cached?.city.name == "Казань")
    }

    @Test @MainActor func testWeatherCacheAgeDescription() async throws {
        let vm = WeatherViewModel(initialCity: .moscow)
        await vm.loadWeather()

        #expect(vm.cacheAgeDescription != nil)
        #expect(vm.formattedUpdateTime != nil)
    }

    @Test func testSwiftDataWeatherDeletion() async throws {
        let schema = Schema([CachedWeatherItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])

        let storage = StorageService(defaults: .standard, modelContainer: container)
        let service = MockWeatherService()
        let weather = try await service.fetchWeather(for: .sochi)

        storage.saveCachedWeather(weather)
        #expect(storage.loadCachedWeather(for: weather.city.id) != nil)

        storage.deleteCachedWeather(for: weather.city.id)
        #expect(storage.loadCachedWeather(for: weather.city.id) == nil)
    }

    @Test @MainActor func testNoInternetNotificationToast() {
        let vm = WeatherViewModel(initialCity: .moscow)
        #expect(!vm.showNoInternetToast)

        vm.triggerNoInternetNotification()
        #expect(vm.showNoInternetToast)

        vm.dismissNoInternetNotification()
        #expect(!vm.showNoInternetToast)
    }
}
