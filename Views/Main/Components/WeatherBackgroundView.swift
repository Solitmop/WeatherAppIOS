//
//  WeatherBackgroundView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный спокойный фон, адаптирующийся под светлую и тёмную темы
public struct WeatherBackgroundView: View {
    public let condition: WeatherCondition?
    @Environment(\.colorScheme) private var colorScheme

    public init(condition: WeatherCondition?) {
        self.condition = condition
    }

    public var body: some View {
        ZStack {
            // Базовый цвет подложки
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            // Спокойный градиент погодных условий для активной цветовой схемы
            let defaultDarkColors = [Color(white: 0.14), Color(white: 0.09)]
            let defaultLightColors = [Color(red: 0.91, green: 0.94, blue: 0.98), Color(red: 0.96, green: 0.97, blue: 0.99)]
            let colors = condition?.backgroundColors(for: colorScheme) ?? (colorScheme == .dark ? defaultDarkColors : defaultLightColors)

            LinearGradient(
                colors: colors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: condition)
            .animation(.easeInOut(duration: 0.35), value: colorScheme)
        }
    }
}
