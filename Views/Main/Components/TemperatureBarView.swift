//
//  TemperatureBarView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный индикатор температурного диапазона дня
public struct TemperatureBarView: View {
    public let dayLow: Double
    public let dayHigh: Double
    public let minWeekTemp: Double
    public let maxWeekTemp: Double
    public let currentTemp: Double?

    public init(
        dayLow: Double,
        dayHigh: Double,
        minWeekTemp: Double,
        maxWeekTemp: Double,
        currentTemp: Double? = nil
    ) {
        self.dayLow = dayLow
        self.dayHigh = dayHigh
        self.minWeekTemp = minWeekTemp
        self.maxWeekTemp = maxWeekTemp
        self.currentTemp = currentTemp
    }

    public var body: some View {
        GeometryReader { geometry in
            let totalRange = max(maxWeekTemp - minWeekTemp, 1.0)
            let width = geometry.size.width

            let startFraction = max(0.0, min(1.0, (dayLow - minWeekTemp) / totalRange))
            let endFraction = max(0.0, min(1.0, (dayHigh - minWeekTemp) / totalRange))

            let barStart = startFraction * width
            let barWidth = max((endFraction - startFraction) * width, 4.0)

            ZStack(alignment: .leading) {
                // Подложка
                Capsule()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 4)

                // Диапазон дня
                Capsule()
                    .fill(Color.orange.opacity(0.85))
                    .frame(width: barWidth, height: 4)
                    .offset(x: barStart)

                // Точка текущей температуры для "Сегодня"
                if let current = currentTemp {
                    let currentFraction = max(0.0, min(1.0, (current - minWeekTemp) / totalRange))
                    let dotX = currentFraction * width

                    Circle()
                        .fill(Color.primary)
                        .frame(width: 6, height: 6)
                        .offset(x: max(0, min(width - 6, dotX - 3)))
                }
            }
        }
        .frame(height: 6)
    }
}
