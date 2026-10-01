//
//  WeatherServiceProtocol.swift
//  WeatherAppIOS
//

import Foundation

/// Ошибки сервиса погоды
public enum WeatherServiceError: LocalizedError, Sendable {
    case cityNotFound
    case networkError(String)
    case invalidResponse
    case locationUnavailable

    public var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "Город не найден"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .locationUnavailable:
            return "Не удалось определить местоположение"
        }
    }
}

/// Протокол сервиса получения погодных данных
public protocol WeatherServiceProtocol: Sendable {
    /// Получение актуальной сводки погоды для указанного города
    func fetchWeather(for city: City) async throws -> CityWeather

    /// Поиск городов по текстовому запросу
    func searchCities(query: String) async throws -> [City]

    /// Получение погоды по географическим координатам (например, текущей геопозиции)
    func fetchWeatherForCoordinates(latitude: Double, longitude: Double) async throws -> CityWeather
}
