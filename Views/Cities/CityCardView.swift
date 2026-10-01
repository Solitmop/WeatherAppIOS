//
//  CityCardView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичная карточка города
public struct CityCardView: View {
    public let weather: CityWeather

    public init(weather: CityWeather) {
        self.weather = weather
    }

    public var body: some View {
        HStack(alignment: .center) {
            // Левая часть: название и регион
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    if weather.city.isCurrentLocation {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text(weather.city.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Text(weather.city.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    WeatherIconView(condition: weather.current.condition)
                        .font(.caption)

                    Text(weather.current.condition.descriptionRu)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }

            Spacer()

            // Правая часть: температура и диапазон
            VStack(alignment: .trailing, spacing: 3) {
                Text(MetricFormatter.temperature(weather.current.temperature, showSign: false))
                    .font(.system(size: 38, weight: .light, design: .rounded))
                    .foregroundStyle(.primary)

                Text("\(MetricFormatter.temperature(weather.current.highTemperature)) / \(MetricFormatter.temperature(weather.current.lowTemperature))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
