//
//  MainViewModel.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var headlines: [Article] = []
    @Published var favoriteArticles: [Article] = []
    private var cancellables = Set<AnyCancellable>()

    private let getHeadlinesUseCase: FetchHeadlinesUseCase
    private let saveFavoriteArticleUseCase: SaveFavoriteArticleUseCase
    private let getFavoriteArticlesUseCase: GetFavoriteArticlesUseCase

    init(getHeadlinesUseCase: FetchHeadlinesUseCase, saveFavoriteArticleUseCase: SaveFavoriteArticleUseCase, getFavoriteArticlesUseCase: GetFavoriteArticlesUseCase) {
        self.getHeadlinesUseCase = getHeadlinesUseCase
        self.saveFavoriteArticleUseCase = saveFavoriteArticleUseCase
        self.getFavoriteArticlesUseCase = getFavoriteArticlesUseCase
    }

    func fetchHeadlines(country: String, categories: [String]) {
        getHeadlinesUseCase.execute(country: country, categories: categories)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion
            }, receiveValue: { [weak self] articles in
                self?.headlines = articles
            })
            .store(in: &cancellables)
    }

    func saveFavorite(article: Article) {
        saveFavoriteArticleUseCase.execute(article: article)
            .sink(receiveCompletion: { completion in
                // Handle completion
            }, receiveValue: { })
            .store(in: &cancellables)
    }

    func fetchFavoriteArticles() {
        getFavoriteArticlesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion
            }, receiveValue: { [weak self] articles in
                self?.favoriteArticles = articles
            })
            .store(in: &cancellables)
    }
}

