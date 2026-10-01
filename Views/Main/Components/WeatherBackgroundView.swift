//
//  WeatherBackgroundView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный спокойный фон без агрессивных эффектов и свечений
public struct WeatherBackgroundView: View {
    public let condition: WeatherCondition?

    public init(condition: WeatherCondition?) {
        self.condition = condition
    }

    public var body: some View {
        ZStack {
            // Базовый цвет фона
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            // Спокойный, минималистичный градиент
            LinearGradient(
                colors: condition?.backgroundColors ?? [Color(white: 0.16), Color(white: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: condition)
        }
    }
}
