//
//  DailyForecastView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный прогноз на неделю
public struct DailyForecastView: View {
    public let daily: [DailyForecast]
    public let currentTemperature: Double

    public init(daily: [DailyForecast], currentTemperature: Double) {
        self.daily = daily
        self.currentTemperature = currentTemperature
    }

    private var minWeekTemp: Double {
        daily.map(\.lowTemperature).min() ?? 0
    }

    private var maxWeekTemp: Double {
        daily.map(\.highTemperature).max() ?? 30
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Заголовок
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("ПРОГНОЗ НА 7 ДНЕЙ")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Список дней
            VStack(spacing: 12) {
                ForEach(Array(daily.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 10) {
                        Text(item.dayTitle)
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .frame(width: 65, alignment: .leading)

                        // Иконка и вероятность осадков
                        HStack(spacing: 4) {
                            Image(systemName: item.condition.sfSymbolName)
                                .font(.subheadline)
                                .foregroundStyle(item.condition.iconColor)
                                .frame(width: 22)

                            if item.precipitationProbability > 0 {
                                Text("\(item.precipitationProbability)%")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.blue)
                                    .frame(width: 28, alignment: .leading)
                            } else {
                                Spacer().frame(width: 28)
                            }
                        }

                        // Мин температура в СИ
                        Text(MetricFormatter.temperature(item.lowTemperature, showSign: false))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, alignment: .trailing)

                        // Индикатор диапазона
                        TemperatureBarView(
                            dayLow: item.lowTemperature,
                            dayHigh: item.highTemperature,
                            minWeekTemp: minWeekTemp,
                            maxWeekTemp: maxWeekTemp,
                            currentTemp: index == 0 ? currentTemperature : nil
                        )

                        // Макс температура в СИ
                        Text(MetricFormatter.temperature(item.highTemperature, showSign: false))
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .frame(width: 32, alignment: .leading)
                    }

                    if index < daily.count - 1 {
                        Divider()
                            .opacity(0.4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
    }
}
