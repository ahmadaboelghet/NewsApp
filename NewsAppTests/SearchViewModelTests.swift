//
//  SearchViewModelTests.swift
//  NewsAppTests
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import XCTest
@testable import NewsApp
import Combine

class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!
    var repository: NewsRepositoryMock!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        repository = NewsRepositoryMock()
        viewModel = SearchViewModel(searchArticlesUseCase: SearchArticlesUseCase(repository: repository), saveFavoriteArticleUseCase: SaveFavoriteArticleUseCase(repository: repository), getFavoriteArticlesUseCase: GetFavoriteArticlesUseCase(repository: repository))
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        repository = nil
        cancellables = nil
        super.tearDown()
    }

    func testSearchArticles() {
        let expectation = self.expectation(description: "Search articles in ViewModel")
        
        viewModel.$searchResults
            .dropFirst()
            .sink(receiveValue: { articles in
                XCTAssertTrue(articles.isEmpty, "Search results should be empty")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        viewModel.searchArticles(query: "test")
        waitForExpectations(timeout: 5, handler: nil)
    }
}
