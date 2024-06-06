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
    func getHeadlines(for country: String, categories: [String]) -> AnyPublisher<[Article], Error>
    func saveFavorite(article: Article)
    func getFavorites() -> [Article]
}

class NewsRepositoryImpl: NewsRepository {
    private let apiService: APIService
    private let realm = try! Realm()

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func getHeadlines(for country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return apiService.fetchHeadlines(for: country, categories: categories)
    }

    func saveFavorite(article: Article) {
        let favorite = FavoriteArticle(article: article)
        try! realm.write {
            realm.add(favorite)
        }
    }

    func getFavorites() -> [Article] {
        return realm.objects(FavoriteArticle.self).map { $0.toArticle() }
    }
    
    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        return apiService.searchArticles(query: query, categories: categories)
    }
}
