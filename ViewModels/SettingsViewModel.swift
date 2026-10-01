//
//  SettingsViewModel.swift
//  WeatherAppIOS
//

import SwiftUI
import Observation

/// ViewModel настроек приложения в минималистичном стиле
@Observable
@MainActor
public final class SettingsViewModel {
    public var appTheme: AppTheme {
        didSet {
            storageService.saveAppTheme(appTheme)
        }
    }

    private let storageService: StorageServiceProtocol

    public init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        self.appTheme = storageService.loadAppTheme()
    }
}
