//
//  LocationService.swift
//  WeatherAppIOS
//

import Foundation
import CoreLocation

/// Протокол сервиса геолокации
public protocol LocationServiceProtocol: Sendable {
    func requestCurrentCoordinates() async throws -> CLLocationCoordinate2D
    var authorizationStatus: CLAuthorizationStatus { get }
}

/// Сервис работы с CoreLocation с асинхронным API на базе Swift Concurrency
@MainActor
public final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    public static let shared = LocationService()

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    /// Запрос текущих географических координат пользователя
    public func requestCurrentCoordinates() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        if status == .denied || status == .restricted {
            throw WeatherServiceError.locationUnavailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.manager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            if let coordinate = locations.last?.coordinate {
                self.locationContinuation?.resume(returning: coordinate)
                self.locationContinuation = nil
            }
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationContinuation?.resume(throwing: error)
            self.locationContinuation = nil
        }
    }
}
