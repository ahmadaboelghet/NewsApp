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
    func getHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error>
    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error>
    func getFavoriteArticles() -> AnyPublisher<[Article], Error>
    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error>
}

class NewsRepositoryImpl: NewsRepository {
    
    private let apiService: APIService
    private let realm: Realm

    init(apiService: APIService) {
        self.apiService = apiService
        self.realm = try! Realm()
    }

    func getHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        // Fetch from API
        let apiPublisher = apiService.fetchHeadlines(for: country, categories: categories)
            .handleEvents(receiveOutput: { articles in
                // Cache articles in Realm
                self.cacheArticles(articles)
            })
            .eraseToAnyPublisher()

        // Fetch from Realm if offline
        let realmPublisher = Future<[Article], Error> { promise in
            let cachedArticles = self.getCachedArticles()
            if cachedArticles.isEmpty {
                promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No cached data available."])))
            } else {
                promise(.success(cachedArticles))
            }
        }.eraseToAnyPublisher()

        return apiPublisher
            .catch { _ in realmPublisher }
            .eraseToAnyPublisher()
    }

    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.realm.write {
                    // Use .modified to update the existing object if it already exists
                    self.realm.add(RealmArticle(from: article), update: .modified)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }


    func getFavoriteArticles() -> AnyPublisher<[Article], Error> {
        // Fetch favorite articles from Realm
        return Future<[Article], Error> { promise in
            let realmArticles = self.realm.objects(RealmArticle.self)
            let articles = realmArticles.map { $0.toArticle() }
            promise(.success(Array(articles)))
        }.eraseToAnyPublisher()
    }

    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        // Implement search with API and cache
        let apiPublisher = apiService.searchArticles(query: query, categories: categories)
            .handleEvents(receiveOutput: { articles in
                // Cache articles in Realm
                self.cacheArticles(articles)
            })
            .eraseToAnyPublisher()

        // Fetch from Realm if offline
        let realmPublisher = Future<[Article], Error> { promise in
            let cachedArticles = self.getCachedArticles(matching: query)
            if cachedArticles.isEmpty {
                promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No cached data available."])))
            } else {
                promise(.success(cachedArticles))
            }
        }.eraseToAnyPublisher()

        return apiPublisher
            .catch { _ in realmPublisher }
            .eraseToAnyPublisher()
    }

    private func cacheArticles(_ articles: [Article]) {
        do {
            try realm.write {
                let realmArticles = articles.map { RealmArticle(from: $0) }
                realm.add(realmArticles, update: .all)
            }
        } catch {
            print("Failed to cache articles: \(error)")
        }
    }

    private func getCachedArticles() -> [Article] {
        let realmArticles = realm.objects(RealmArticle.self)
        return realmArticles.map { $0.toArticle() }
    }

    private func getCachedArticles(matching query: String) -> [Article] {
        let realmArticles = realm.objects(RealmArticle.self).filter("title CONTAINS[c] %@", query)
        return realmArticles.map { $0.toArticle() }
    }
}



//class NewsRepositoryImpl: NewsRepository {
//    private let apiService: APIService
//    private let favoritesKey = "favoriteArticles"
//
//    init(apiService: APIService) {
//        self.apiService = apiService
//    }
//
//    func getHeadlines(country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
//        return apiService.fetchHeadlines(for: country, categories: categories)
//    }
//
//    func saveFavoriteArticle(_ article: Article) -> AnyPublisher<Void, Error> {
//        var favoriteArticles = getFavoriteArticlesSync()
//        favoriteArticles.append(article)
//        if let encoded = try? JSONEncoder().encode(favoriteArticles) {
//            UserDefaults.standard.set(encoded, forKey: favoritesKey)
//        }
//        return Just(())
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//    }
//
//    func getFavoriteArticles() -> AnyPublisher<[Article], Error> {
//        return Just(getFavoriteArticlesSync())
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//    }
//
//    private func getFavoriteArticlesSync() -> [Article] {
//        if let savedArticles = UserDefaults.standard.object(forKey: favoritesKey) as? Data {
//            if let decodedArticles = try? JSONDecoder().decode([Article].self, from: savedArticles) {
//                return decodedArticles
//            }
//        }
//        return []
//    }
//
//    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
//        return apiService.searchArticles(query: query, categories: categories)
//    }
//}
