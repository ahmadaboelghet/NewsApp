//
//  APIService.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Alamofire
import Combine

class APIService {
    private let apiKey = "39bdc2d32e5948dd947ce51449032cda"
    
    // Default categories in case user doesn't provide any
    private let defaultCategories = ["general", "business", "technology"]

    // Fetch headlines with the option to provide custom categories
    func fetchHeadlines(for country: String, categories: [String]? = nil) -> AnyPublisher<[Article], Error> {
        let categoriesToUse = categories ?? defaultCategories
        let publishers = categoriesToUse.map { category in
            Future<[Article], Error> { promise in
                let urlString = "https://newsapi.org/v2/top-headlines?country=\(country)&category=\(category)&apiKey=\(self.apiKey)"
                AF.request(urlString).responseDecodable(of: NewsResponse.self) { response in
                    switch response.result {
                    case .success(let newsResponse):
                        promise(.success(newsResponse.articles))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { articlesArray -> [Article] in
                // Flatten the array of arrays into a single array of articles
                return articlesArray.flatMap { $0 }
            }
            .map { articles in
                articles.sorted(by: { $0.publishedAt ?? "" > $1.publishedAt ?? "" }) // Sorting by date
            }
            .eraseToAnyPublisher()
    }
    
    // Search articles with the option to provide custom categories
    func searchArticles(query: String, categories: [String]? = nil) -> AnyPublisher<[Article], Error> {
        let categoriesToUse = categories ?? defaultCategories
        let queries = categoriesToUse.map { category in
            "\(query) AND \(category)"
        }
        
        let publishers = queries.map { searchQuery in
            Future<[Article], Error> { promise in
                let urlString = "https://newsapi.org/v2/everything?q=\(searchQuery)&apiKey=\(self.apiKey)"
                AF.request(urlString).responseDecodable(of: NewsResponse.self) { response in
                    switch response.result {
                    case .success(let newsResponse):
                        promise(.success(newsResponse.articles))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { articlesArray -> [Article] in
                // Flatten the array of arrays into a single array of articles
                return articlesArray.flatMap { $0 }
            }
            .map { articles in
                articles.sorted(by: { $0.publishedAt ?? "" > $1.publishedAt ?? "" }) // Sorting by date
            }
            .eraseToAnyPublisher()
    }
}

