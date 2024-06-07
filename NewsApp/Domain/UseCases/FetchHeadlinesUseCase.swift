//
//  FetchHeadlinesUseCase.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Combine

class FetchHeadlinesUseCase {
    private let repository: NewsRepository

    init(repository: NewsRepository) {
        self.repository = repository
    }

    func execute(country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return repository.getHeadlines(country: country, categories: categories)
    }
}
