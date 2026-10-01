//
//  WeatherMainView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Главный экран погоды в минималистичном стиле
public struct WeatherMainView: View {
    @Bindable var weatherVM: WeatherViewModel
    @Bindable var cityListVM: CityListViewModel
    @Bindable var settingsVM: SettingsViewModel

    @State private var showCityListSheet = false
    @State private var showSettingsSheet = false

    public init(
        weatherVM: WeatherViewModel,
        cityListVM: CityListViewModel,
        settingsVM: SettingsViewModel
    ) {
        self.weatherVM = weatherVM
        self.cityListVM = cityListVM
        self.settingsVM = settingsVM
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public var body: some View {
        ZStack {
            // Спокойный фон
            WeatherBackgroundView(condition: weatherVM.currentWeather?.current.condition)

            if weatherVM.isLoading && weatherVM.currentWeather == nil {
                ProgressView()
            } else if let weather = weatherVM.currentWeather {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Верхняя панель
                        HStack {
                            Button {
                                showSettingsSheet = true
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .padding(8)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Button {
                                Task {
                                    await weatherVM.loadCurrentLocationWeather()
                                }
                            } label: {
                                Image(systemName: "location")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .padding(8)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
                                    .clipShape(Circle())
                            }

                            Button {
                                showCityListSheet = true
                            } label: {
                                Image(systemName: "list.bullet")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .padding(8)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        // Главный заголовок
                        CurrentWeatherHeaderView(
                            city: weather.city,
                            current: weather.current
                        )

                        // Почасовой прогноз
                        let timeZone = TimeZone(identifier: weather.city.timeZoneIdentifier) ?? .current
                        HourlyForecastView(
                            hourly: weather.hourly,
                            timeZone: timeZone
                        )

                        // Прогноз на 7 дней
                        DailyForecastView(
                            daily: weather.daily,
                            currentTemperature: weather.current.temperature
                        )

                        // Сетка метрик в системе СИ
                        LazyVGrid(columns: columns, spacing: 12) {
                            WindMetricCard(
                                speedMps: weather.metrics.windSpeedMps,
                                direction: weather.metrics.windDirection,
                                gustMps: weather.metrics.windGustMps
                            )

                            PressureMetricCard(
                                pressureHpa: weather.metrics.pressureHpa
                            )

                            HumidityMetricCard(
                                humidity: weather.metrics.humidityPercentage,
                                dewPoint: weather.metrics.dewPointCelsius
                            )

                            UVMetricCard(
                                uvIndex: weather.metrics.uvIndex,
                                status: weather.metrics.uvShortStatus
                            )

                            SunTimesMetricCard(
                                sunrise: weather.metrics.sunrise,
                                sunset: weather.metrics.sunset,
                                timeZone: timeZone
                            )

                            VisibilityMetricCard(
                                visibilityKm: weather.metrics.visibilityKm
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .refreshable {
                    await weatherVM.refresh()
                }
            } else if let error = weatherVM.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)

                    Text(error)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Повторить") {
                        Task {
                            await weatherVM.loadWeather()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .sheet(isPresented: $showCityListSheet) {
            CityListView(
                cityListVM: cityListVM,
                onSelectCity: { selectedCity in
                    showCityListSheet = false
                    Task {
                        await weatherVM.selectCity(selectedCity)
                    }
                }
            )
            .preferredColorScheme(settingsVM.appTheme.colorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(settingsVM: settingsVM)
                .preferredColorScheme(settingsVM.appTheme.colorScheme)
        }
        .preferredColorScheme(settingsVM.appTheme.colorScheme)
        .task {
            if weatherVM.currentWeather == nil {
                await weatherVM.loadWeather()
            }
        }
    }
}
