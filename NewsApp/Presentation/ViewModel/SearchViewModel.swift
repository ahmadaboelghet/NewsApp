//
//  SearchViewModel.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchResults: [Article] = []
    private var cancellables = Set<AnyCancellable>()

    private let searchArticlesUseCase: SearchArticlesUseCase

    init(searchArticlesUseCase: SearchArticlesUseCase) {
        self.searchArticlesUseCase = searchArticlesUseCase
    }

    func searchArticles(query: String) {
        let categories = UserDefaults.standard.stringArray(forKey: "selectedCategories") ?? ["general"]

        searchArticlesUseCase.execute(query: query, categories: categories)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion
            }, receiveValue: { [weak self] articles in
                self?.searchResults = articles
            })
            .store(in: &cancellables)
    }
}
