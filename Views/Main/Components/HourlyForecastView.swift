//
//  HourlyForecastView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный почасовой прогноз погоды
public struct HourlyForecastView: View {
    public let hourly: [HourlyForecast]
    public let timeZone: TimeZone

    public init(hourly: [HourlyForecast], timeZone: TimeZone = .current) {
        self.hourly = hourly
        self.timeZone = timeZone
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Заголовок
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("ПОЧАСОВОЙ ПРОГНОЗ")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Карусель часов
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(hourly) { item in
                        VStack(spacing: 8) {
                            Text(item.timeString(timeZone: timeZone))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            WeatherIconView(condition: item.condition)
                                .font(.body)
                                .frame(height: 22)

                            if item.precipitationProbability > 0 {
                                Text("\(item.precipitationProbability)%")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.blue)
                            } else {
                                Text(" ")
                                    .font(.system(size: 10))
                            }

                            Text(MetricFormatter.temperature(item.temperature))
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        }
                        .frame(minWidth: 48)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
    }
}
