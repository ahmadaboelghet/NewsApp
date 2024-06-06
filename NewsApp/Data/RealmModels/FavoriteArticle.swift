//
//  FavoriteArticle.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import RealmSwift

class FavoriteArticle: Object {
    @objc dynamic var title = ""
    @objc dynamic var date = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var source = ""
    @objc dynamic var descriptionText = ""

    convenience init(article: Article) {
        self.init()
        self.title = article.title
        self.date = article.publishedAt
        self.imageUrl = article.urlToImage ?? ""
        self.source = article.source.name
        self.descriptionText = article.description
    }

    func toArticle() -> Article {
        return Article(title: title, publishedAt: date, urlToImage: imageUrl, source: Source(name: source), description: descriptionText)
    }
}
