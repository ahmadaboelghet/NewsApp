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

    func fetchHeadlines(for country: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        let categoriesString = categories.joined(separator: ",")
        let urlString = "https://newsapi.org/v2/top-headlines?country=\(country)&category=\(categoriesString)&apiKey=\(apiKey)"
        
        return Future { promise in
            AF.request(urlString).responseDecodable(of: NewsResponse.self) { response in
                switch response.result {
                case .success(let newsResponse):
                    promise(.success(newsResponse.articles))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[Article], Error> {
        let categoriesString = categories.joined(separator: ",")
        let urlString = "https://newsapi.org/v2/everything?q=\(query)&apiKey=\(apiKey)"
        return Future { promise in
            AF.request(urlString).responseDecodable(of: NewsResponse.self) { response in
                switch response.result {
                case .success(let newsResponse):
                    promise(.success(newsResponse.articles))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
