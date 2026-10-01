//
//  WeatherApp.swift
//  WeatherAppIOS
//

import SwiftUI
import SwiftData

@main
struct WeatherApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var weatherVM = WeatherViewModel()
    @State private var cityListVM = CityListViewModel()
    @State private var settingsVM = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            WeatherMainView(
                weatherVM: weatherVM,
                cityListVM: cityListVM,
                settingsVM: settingsVM
            )
            .preferredColorScheme(settingsVM.appTheme.colorScheme)
        }
        .modelContainer(for: CachedWeatherItem.self)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Сохранение данных в SwiftData и UserDefaults перед сном / сворачиванием
            if newPhase == .inactive || newPhase == .background {
                weatherVM.saveStateBeforeSleep()
                cityListVM.saveStateBeforeSleep()
            }
        }
    }
}
