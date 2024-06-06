//
//  NewsRepository.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine
import RealmSwift

protocol NewsRepository {
    func fetchHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error>
    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error>
    func getFavoriteArticles() -> AnyPublisher<[FavoriteArticle], Error>
    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error>
}

import Combine

class NewsRepositoryImpl: NewsRepository {
    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func fetchHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return apiService.fetchHeadlines(for: country, categories: categories)
    }

    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error> {
        // Implement saving favorite article logic
        // For example purposes, returning an empty publisher
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getFavoriteArticles() -> AnyPublisher<[FavoriteArticle], Error> {
        // Implement fetching favorite articles logic
        // For example purposes, returning an empty publisher
        return Just([FavoriteArticle]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return apiService.searchArticles(query: query, categories: categories)
    }
}
