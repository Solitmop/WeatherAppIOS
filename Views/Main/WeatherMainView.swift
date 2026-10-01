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
                        // Верхняя панель управления
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

                        // Индикатор офлайн-режима с давностью обновления кэша
                        if weatherVM.isFromCache {
                            HStack(spacing: 6) {
                                Image(systemName: "wifi.slash")
                                    .font(.caption2)

                                if let age = weatherVM.cacheAgeDescription {
                                    Text("Офлайн • Обновлено \(age)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                } else {
                                    Text("Офлайн-режим (сохраненные данные)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
                            .clipShape(Capsule())
                            .padding(.top, -6)
                        }

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
                        DailyForecastView(daily: weather.daily)

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
        .overlay(alignment: .top) {
            if weatherVM.showNoInternetToast {
                HStack(spacing: 10) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Отсутствует интернет. Показаны сохраненные данные.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)

                    Spacer(minLength: 4)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            weatherVM.dismissNoInternetNotification()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(4)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(red: 0.15, green: 0.15, blue: 0.18).opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: weatherVM.showNoInternetToast)
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
