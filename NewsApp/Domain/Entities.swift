//
//  Entities.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation

struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Equatable {
    var id: UUID?// Add a unique identifier
    let title: String?
    let publishedAt: String?
    let urlToImage: String?
    let source: Source?
    let description: String?
    let url: String?
}

struct Source: Codable, Equatable {
    let name: String?
}
