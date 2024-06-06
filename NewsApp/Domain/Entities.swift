//
//  Entities.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation

struct NewsResponse: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let title: String
    let publishedAt: String
    let urlToImage: String?
    let source: Source
    let description: String?
    let url: String
}

struct Source: Decodable {
    let name: String
}
