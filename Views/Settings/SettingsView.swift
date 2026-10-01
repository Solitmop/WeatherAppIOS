//
//  SettingsView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Минималистичный экран настроек
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settingsVM: SettingsViewModel

    public init(settingsVM: SettingsViewModel) {
        self.settingsVM = settingsVM
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Внешний вид
                Section {
                    Picker("Тема оформления", selection: $settingsVM.appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Тема")
                }

                // Единицы СИ
                Section {
                    LabeledContent("Температура", value: "°C (Цельсий)")
                    LabeledContent("Скорость ветра", value: "м/с (Метры в секунду)")
                    LabeledContent("Давление", value: "гПа (Гектопаскали)")
                    LabeledContent("Видимость", value: "км (Километры)")
                } header: {
                    Text("Единицы измерения (СИ)")
                } footer: {
                    Text("Все показатели отображаются строго по Международной системе единиц (СИ).")
                }

                // Информация
                Section {
                    LabeledContent("Архитектура", value: "SwiftUI + MVVM")
                    LabeledContent("Реактивность", value: "Apple Observation")
                    LabeledContent("Версия", value: "1.0.0")
                } header: {
                    Text("О приложении")
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}
