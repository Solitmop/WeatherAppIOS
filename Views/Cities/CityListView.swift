//
//  CityListView.swift
//  WeatherAppIOS
//

import SwiftUI

/// Экран 2: Список избранных городов
public struct CityListView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var cityListVM: CityListViewModel
    public var onSelectCity: (City) -> Void

    @State private var showAddCitySheet = false

    public init(
        cityListVM: CityListViewModel,
        onSelectCity: @escaping (City) -> Void
    ) {
        self.cityListVM = cityListVM
        self.onSelectCity = onSelectCity
    }

    public var body: some View {
        NavigationStack {
            savedCitiesList
                .navigationTitle("Избранные города")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddCitySheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Готово") {
                            dismiss()
                        }
                        .fontWeight(.medium)
                    }
                }
                .sheet(isPresented: $showAddCitySheet) {
                    AddCityView(
                        cityListVM: cityListVM,
                        onSelectCity: { selectedCity in
                            onSelectCity(selectedCity)
                            dismiss()
                        }
                    )
                }
                .task {
                    if cityListVM.savedCitiesWeather.isEmpty {
                        await cityListVM.loadSavedCitiesWeather()
                    }
                }
        }
    }

    // MARK: - Список сохраненных городов

    private var savedCitiesList: some View {
        List {
            ForEach(cityListVM.savedCitiesWeather) { weather in
                CityCardView(weather: weather)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelectCity(weather.city)
                        dismiss()
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
                    "Нет избранных городов",
                    systemImage: "star.slash",
                    description: Text("Нажмите на кнопку «+», чтобы найти и добавить города.")
                )
            }
        }
    }
}
