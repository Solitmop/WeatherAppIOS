//
//  WeatherAppIOSTests.swift
//  WeatherAppIOSTests
//

import Testing
import Foundation
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
}
