//
//  DailyForecastView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный прогноз на неделю в системе СИ (°C)
public struct DailyForecastView: View {
    public let daily: [DailyForecast]

    public init(daily: [DailyForecast], currentTemperature: Double? = nil) {
        self.daily = daily
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("ПРОГНОЗ НА 7 ДНЕЙ")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Список дней
            VStack(spacing: 10) {
                ForEach(Array(daily.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .center) {
                        // День недели и дата
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.dayTitle)
                                .font(.body)
                                .fontWeight(index == 0 ? .semibold : .medium)
                                .foregroundStyle(.primary)

                            Text(formatDate(item.date))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 85, alignment: .leading)

                        Spacer()

                        // Иконка погоды и вероятность осадков
                        HStack(spacing: 6) {
                            WeatherIconView(condition: item.condition)
                                .font(.title3)

                            if item.precipitationProbability > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 8))
                                    Text("\(item.precipitationProbability)%")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        .frame(minWidth: 60, alignment: .center)

                        Spacer()

                        // Температуры: максимум и минимум
                        HStack(spacing: 12) {
                            Text(MetricFormatter.temperature(item.highTemperature))
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, alignment: .trailing)

                            Text(MetricFormatter.temperature(item.lowTemperature))
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .foregroundStyle(.secondary)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 2)

                    if index < daily.count - 1 {
                        Divider()
                            .opacity(0.4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }
}
