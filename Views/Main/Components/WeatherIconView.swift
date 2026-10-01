//
//  WeatherIconView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Компонент отображения погодной иконки SF Symbols с послойным раскрашиванием (Palette)
public struct WeatherIconView: View {
    public let condition: WeatherCondition

    public init(condition: WeatherCondition) {
        self.condition = condition
    }

    public var body: some View {
        Group {
            switch condition {
            case .partlyCloudyDay:
                // Солнце за тучей: облако серое (слой 1), солнце желтое (слой 2)
                Image(systemName: "cloud.sun.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.gray, Color.yellow)

            case .partlyCloudyNight:
                // Луна за тучей: облако серое (слой 1), луна индиго (слой 2)
                Image(systemName: "cloud.moon.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.gray, Color.indigo)

            case .drizzle, .rain, .heavyRain:
                // Дождь: туча серая (слой 1), капли синие (слой 2)
                Image(systemName: condition.sfSymbolName)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.gray, Color.blue)

            case .thunderstorm:
                // Гроза: туча серая, молния желтая, капли синие
                Image(systemName: "cloud.bolt.rain.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.gray, Color.yellow, Color.blue)

            case .snow, .sleet:
                // Снег: туча серая, снежинки голубые
                Image(systemName: condition.sfSymbolName)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.gray, Color.cyan)

            case .clearDay:
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Color.orange)

            case .clearNight:
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Color.indigo)

            case .cloudy, .overcast, .fog:
                Image(systemName: condition.sfSymbolName)
                    .foregroundStyle(Color.gray)

            case .windy:
                Image(systemName: "wind")
                    .foregroundStyle(Color.teal)
            }
        }
    }
}
