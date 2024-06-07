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
    @Published var selectedCategories: [String] = ["general"] // Default categories
    private var cancellables = Set<AnyCancellable>()
    
    private let searchArticlesUseCase: SearchArticlesUseCase
    
    init(searchArticlesUseCase: SearchArticlesUseCase) {
        self.searchArticlesUseCase = searchArticlesUseCase
    }
    
    func updateCategories(_ categories: [String]) {
        selectedCategories = categories
    }
    
    func searchArticles(query: String) {
        searchArticlesUseCase.execute(query: query, categories: selectedCategories)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion
                if case .failure(let error) = completion {
                    print("Error searching articles: \(error)")
                }
            }, receiveValue: { [weak self] articles in
                self?.searchResults = articles
            })
            .store(in: &cancellables)
    }
}
