//
//  CurrentWeatherHeaderView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный заголовок текущей погоды в системе СИ (°C)
public struct CurrentWeatherHeaderView: View {
    public let city: City
    public let current: CurrentWeather

    public init(city: City, current: CurrentWeather) {
        self.city = city
        self.current = current
    }

    public var body: some View {
        VStack(spacing: 4) {
            // Город
            Text(city.name)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundStyle(.primary)

            // Статус погоды
            Text(current.condition.descriptionRu)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            // Температура по шкале Цельсия (СИ)
            Text(MetricFormatter.temperature(current.temperature, showSign: false))
                .font(.system(size: 84, weight: .thin, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.vertical, -8)

            // Мин / Макс и Ощущается как
            HStack(spacing: 12) {
                Text("Макс: \(MetricFormatter.temperature(current.highTemperature)), мин: \(MetricFormatter.temperature(current.lowTemperature))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("•")
                    .foregroundStyle(.tertiary)

                Text("Ощущается как \(MetricFormatter.temperature(current.feelsLike))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 12)
    }
}
