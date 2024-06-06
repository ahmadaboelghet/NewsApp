//
//  SaveFavoriteArticleUseCase.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine

class SaveFavoriteArticleUseCase {
    private let repository: NewsRepository

    init(repository: NewsRepository) {
        self.repository = repository
    }

    func execute(article: Article) {
        repository.saveFavorite(article: article)
    }
}
