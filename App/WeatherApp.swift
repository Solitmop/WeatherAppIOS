//
//  WeatherApp.swift
//  WeatherAppIOS
//

import SwiftUI

@main
struct WeatherApp: App {
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
    }
}
