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
    case noInternetConnection

    public var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "Город не найден"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .noInternetConnection:
            return "Отсутствует подключение к интернету"
        }
    }
}

/// Протокол сервиса получения погодных данных
public protocol WeatherServiceProtocol: Sendable {
    /// Получение актуальной сводки погоды для указанного города
    func fetchWeather(for city: City) async throws -> CityWeather

    /// Поиск городов по текстовому запросу
    func searchCities(query: String) async throws -> [City]
}
