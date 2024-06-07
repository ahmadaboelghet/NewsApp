//
//  MainViewModelTests.swift
//  NewsAppTests
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import XCTest
@testable import NewsApp
import Combine

class MainViewModelTests: XCTestCase {
    var viewModel: MainViewModel!
    var repository: NewsRepositoryMock!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repository = NewsRepositoryMock()
        viewModel = MainViewModel(fetchHeadlinesUseCase: FetchHeadlinesUseCase(repository: repository))
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        repository = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchHeadlines() {
        let expectation = self.expectation(description: "Fetch headlines in ViewModel")
        
        viewModel.$headlines
            .dropFirst()
            .sink(receiveValue: { articles in
                XCTAssertFalse(articles.isEmpty, "Articles should not be empty")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.fetchHeadlines()
        waitForExpectations(timeout: 5, handler: nil)
    }
}

class NewsRepositoryMock: NewsRepository {
    
    func fetchHeadlines(country: String, categories: [String]) -> AnyPublisher<[NewsApp.Article], any Error> {
        let source = Source(name: "Test Source")
        let articles = [
            Article(
                title: "Test Article",
                publishedAt: "2024-06-06T12:00:00Z",
                urlToImage: "https://test.com/image.jpg",
                source: source,
                description: "This is a test article.",
                url: "https://test.com"
            )
        ]
        return Just(articles)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
    func saveFavoriteArticle(_ article: NewsApp.Article) -> AnyPublisher<Void, any Error> {
        return Just(())
                   .setFailureType(to: Error.self)
                   .eraseToAnyPublisher()
    }
    
    func getFavoriteArticles() -> AnyPublisher<[NewsApp.FavoriteArticle], any Error> {
        return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
    
    func searchArticles(query: String, categories: [String]) -> AnyPublisher<[NewsApp.Article], any Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
