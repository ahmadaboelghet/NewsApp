//
//  SearchArticlesUseCase.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine

class SearchArticlesUseCase {
    private let repository: NewsRepository

    init(repository: NewsRepository) {
        self.repository = repository
    }

    func execute(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return repository.searchArticles(query: query, categories: categories)
    }
}
