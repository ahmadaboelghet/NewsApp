//
//  GetFavoriteArticlesUseCase.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine

class GetFavoriteArticlesUseCase {
    private let repository: NewsRepository

    init(repository: NewsRepository) {
        self.repository = repository
    }

    func execute() -> [Article] {
        return repository.getFavorites()
    }
}
