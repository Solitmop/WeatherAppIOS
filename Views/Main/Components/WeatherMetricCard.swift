//
//  WeatherMetricCard.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичная карточка метеорологической метрики
public struct WeatherMetricCard<Content: View>: View {
    public let icon: String
    public let title: String
    public let content: Content

    public init(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Заголовок
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 110)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Карточки в системе СИ (м/с, гПа, °C, км)

public struct WindMetricCard: View {
    public let speedMps: Double
    public let direction: String
    public let gustMps: Double?

    public var body: some View {
        WeatherMetricCard(icon: "wind", title: "Ветер (СИ)") {
            VStack(alignment: .leading, spacing: 4) {
                Text(MetricFormatter.windSpeed(speedMps))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Направление: \(direction)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 2)

                if let gust = gustMps {
                    Text("Порывы до \(MetricFormatter.windSpeed(gust))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

public struct PressureMetricCard: View {
    public let pressureHpa: Double

    public var body: some View {
        WeatherMetricCard(icon: "gauge.with.dots.needle.bottom.50percent", title: "Давление (СИ)") {
            VStack(alignment: .leading, spacing: 4) {
                Text(MetricFormatter.pressure(pressureHpa))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                let isNormal = pressureHpa >= 1010 && pressureHpa <= 1018
                Text(isNormal ? "Нормальное" : (pressureHpa > 1018 ? "Повышенное" : "Пониженное"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

public struct HumidityMetricCard: View {
    public let humidity: Int
    public let dewPoint: Double

    public var body: some View {
        WeatherMetricCard(icon: "humidity.fill", title: "Влажность") {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(humidity)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text("Точка росы \(MetricFormatter.temperature(dewPoint))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

public struct UVMetricCard: View {
    public let uvIndex: Int
    public let status: String

    public var body: some View {
        WeatherMetricCard(icon: "sun.max.fill", title: "УФ-индекс") {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(uvIndex)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

public struct SunTimesMetricCard: View {
    public let sunrise: Date
    public let sunset: Date
    public let timeZone: TimeZone

    public var body: some View {
        WeatherMetricCard(icon: "sunrise.fill", title: "Восход и закат") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Восход")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(WeatherUIHelper.formatTime(sunrise, timeZone: timeZone))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Закат")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(WeatherUIHelper.formatTime(sunset, timeZone: timeZone))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, 4)

                Spacer(minLength: 2)
            }
        }
    }
}

public struct VisibilityMetricCard: View {
    public let visibilityKm: Double

    public var body: some View {
        WeatherMetricCard(icon: "eye.fill", title: "Видимость") {
            VStack(alignment: .leading, spacing: 4) {
                Text(MetricFormatter.visibility(visibilityKm))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text(visibilityKm >= 10 ? "Отличная" : "Ограниченная")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
