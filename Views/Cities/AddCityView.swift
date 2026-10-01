//
//  AddCityView.swift
//  WeatherAppIOS
//

import SwiftUI

/// 4-й экран: Поиск и добавление новых городов
public struct AddCityView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var cityListVM: CityListViewModel
    public var onSelectCity: ((City) -> Void)?

    private let popularCities: [City] = [
        .moscow,
        .saintPetersburg,
        .kazan,
        .yekaterinburg,
        .novosibirsk,
        .sochi,
        .nizhnyNovgorod,
        .samara,
        .vladivostok,
        .kaliningrad,
        .krasnoyarsk
    ]

    public init(
        cityListVM: CityListViewModel,
        onSelectCity: ((City) -> Void)? = nil
    ) {
        self.cityListVM = cityListVM
        self.onSelectCity = onSelectCity
    }

    public var body: some View {
        NavigationStack {
            List {
                if !cityListVM.searchQuery.isEmpty {
                    searchResultsSection
                } else {
                    popularCitiesSection
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Добавить город")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $cityListVM.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск по городам России"
            )
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

    // MARK: - Результаты поиска

    @ViewBuilder
    private var searchResultsSection: some View {
        if cityListVM.isSearching {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .listRowBackground(Color.clear)
        } else if cityListVM.searchResults.isEmpty {
            ContentUnavailableView.search(text: cityListVM.searchQuery)
        } else {
            Section("Результаты поиска") {
                ForEach(cityListVM.searchResults) { city in
                    cityRow(for: city)
                }
            }
        }
    }

    // MARK: - Популярные города

    private var popularCitiesSection: some View {
        Section("Популярные города России") {
            ForEach(popularCities) { city in
                cityRow(for: city)
            }
        }
    }

    // MARK: - Строка города

    private func cityRow(for city: City) -> some View {
        let isSaved = cityListVM.isCitySaved(city)

        return HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(city.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(city.region)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSaved {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.secondary)
                    Text("В избранном")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    Task {
                        await cityListVM.addCity(city)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                if !isSaved {
                    await cityListVM.addCity(city)
                }
                onSelectCity?(city)
                dismiss()
            }
        }
    }
}
