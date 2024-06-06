//
//  MainViewModel.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var headlines: [Article] = []
    private var cancellables = Set<AnyCancellable>()

    private let fetchHeadlinesUseCase: FetchHeadlinesUseCase

    init(fetchHeadlinesUseCase: FetchHeadlinesUseCase) {
        self.fetchHeadlinesUseCase = fetchHeadlinesUseCase
    }

    func fetchHeadlines() {
        let country = UserDefaults.standard.string(forKey: "selectedCountry") ?? "us"
        let categories = UserDefaults.standard.stringArray(forKey: "selectedCategories") ?? ["general"]
        
        fetchHeadlinesUseCase.execute(country: country, categories: categories)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion
            }, receiveValue: { [weak self] articles in
                self?.headlines = articles
            })
            .store(in: &cancellables)
    }
}
