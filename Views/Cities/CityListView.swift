//
//  CityListView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Экран списка городов и поиска по городам
public struct CityListView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var cityListVM: CityListViewModel
    public var onSelectCity: (City) -> Void

    public init(
        cityListVM: CityListViewModel,
        onSelectCity: @escaping (City) -> Void
    ) {
        self.cityListVM = cityListVM
        self.onSelectCity = onSelectCity
    }

    public var body: some View {
        NavigationStack {
            Group {
                if !cityListVM.searchQuery.isEmpty {
                    searchResultsView
                } else {
                    savedCitiesView
                }
            }
            .navigationTitle("Города")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $cityListVM.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск по городам"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .task {
                if cityListVM.savedCitiesWeather.isEmpty {
                    await cityListVM.loadSavedCitiesWeather()
                }
            }
        }
    }

    // MARK: - Список сохраненных городов

    private var savedCitiesView: some View {
        List {
            ForEach(cityListVM.savedCitiesWeather) { weather in
                CityCardView(weather: weather)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelectCity(weather.city)
                    }
            }
            .onDelete { indexSet in
                cityListVM.deleteCity(at: indexSet)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await cityListVM.loadSavedCitiesWeather()
        }
        .overlay {
            if cityListVM.savedCitiesWeather.isEmpty && !cityListVM.isLoading {
                ContentUnavailableView(
                    "Список пуст",
                    systemImage: "building.2",
                    description: Text("Найдите нужный город через поиск.")
                )
            }
        }
    }

    // MARK: - Результаты поиска

    private var searchResultsView: some View {
        List {
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
                ForEach(cityListVM.searchResults) { city in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(city.name)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(city.region)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if cityListVM.isCitySaved(city) {
                            Text("Добавлен")
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
                        onSelectCity(city)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
