//
//  NewsRepository.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

//import Foundation
//import Combine
//import RealmSwift
//
//protocol NewsRepository {
//    func fetchHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error>
//    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error>
//    func getFavoriteArticles() -> AnyPublisher<[FavoriteArticle], Error>
//    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error>
//}
//
//import Combine
//
//class NewsRepositoryImpl: NewsRepository {
//    private let apiService: APIService
//
//    init(apiService: APIService) {
//        self.apiService = apiService
//    }
//
//    func fetchHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
//        return apiService.fetchHeadlines(for: country, categories: categories)
//    }
//
//    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error> {
//        // Implement saving favorite article logic
//        // For example purposes, returning an empty publisher
//        return Just(())
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//    }
//
//    func getFavoriteArticles() -> AnyPublisher<[FavoriteArticle], Error> {
//        // Implement fetching favorite articles logic
//        // For example purposes, returning an empty publisher
//        return Just([FavoriteArticle]())
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//    }
//
//    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
//        return apiService.searchArticles(query: query, categories: categories)
//    }
//}

import Foundation
import Combine
import RealmSwift

//protocol NewsRepository {
//    func getHeadlines(country: String, category: String) -> AnyPublisher<[Article], Error>
//    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error>
//    func getFavoriteArticles() -> AnyPublisher<[Article], Error>
//    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error>
//}
//import Combine

protocol NewsRepository {
    func getHeadlines(country: String, category: String) -> AnyPublisher<[Article], Error>
    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error>
    func getFavoriteArticles() -> AnyPublisher<[Article], Error>
    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error>
}

class NewsRepositoryImpl: NewsRepository {
    private let apiService: APIService
    private let favoritesKey = "favoriteArticles"

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func getHeadlines(country: String, category: String) -> AnyPublisher<[Article], Error> {
        return apiService.fetchHeadlines(for: country, categories: [category])
    }

    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error> {
        var favoriteArticles = getFavoriteArticlesSync()
        favoriteArticles.append(article)
        if let encoded = try? JSONEncoder().encode(favoriteArticles) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getFavoriteArticles() -> AnyPublisher<[Article], Error> {
        return Just(getFavoriteArticlesSync())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func getFavoriteArticlesSync() -> [Article] {
        if let savedArticles = UserDefaults.standard.object(forKey: favoritesKey) as? Data {
            if let decodedArticles = try? JSONDecoder().decode([Article].self, from: savedArticles) {
                return decodedArticles
            }
        }
        return []
    }

    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return apiService.searchArticles(query: query, categories: categories)
    }
}
