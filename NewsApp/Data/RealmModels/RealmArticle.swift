//
//  RealmArticle.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import RealmSwift

class RealmArticle: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var publishedAt: String
    @Persisted var urlToImage: String?
    @Persisted var source: RealmSource?
    @Persisted var articleDescription: String
    @Persisted var url: String

    convenience init(from article: Article) {
        self.init()
        self.id = article.url ?? ""
        self.title = article.title ?? ""
        self.publishedAt = article.publishedAt ?? ""
        self.urlToImage = article.urlToImage
        self.source = article.source != nil ? RealmSource(from: article.source!) : nil
        self.articleDescription = article.description ?? ""
        self.url = article.url ?? ""
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    func toArticle() -> Article {
        return Article(
            title: title,
            publishedAt: publishedAt,
            urlToImage: urlToImage,
            source: source?.toSource(),
            description: articleDescription,
            url: url
        )
    }
}

class RealmSource: Object {
    @Persisted var name: String

    convenience init(from source: Source) {
        self.init()
        self.name = source.name ?? ""
    }

    func toSource() -> Source {
        return Source(name: name)
    }
}
