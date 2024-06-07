//
//  NewsRepositoryTests.swift
//  NewsAppTests
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import XCTest
@testable import NewsApp
import Combine

class NewsRepositoryTests: XCTestCase {
    var repository: NewsRepositoryImpl!
    var apiService: APIServiceMock!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        apiService = APIServiceMock()
        repository = NewsRepositoryImpl(apiService: apiService)
        cancellables = []
    }

    override func tearDown() {
        repository = nil
        apiService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchHeadlines() {
        let expectation = self.expectation(description: "Fetch headlines from repository")
        var articles: [Article] = []

        repository.getHeadlines(country: "us", categories: ["business"])
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Failed with error: \(error)")
                }
            }, receiveValue: { fetchedArticles in
                articles = fetchedArticles
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertFalse(articles.isEmpty, "Articles should not be empty")
    }
}

import Combine

class APIServiceMock: APIService {
    override func fetchHeadlines(for country: String, categories: [String]?) -> AnyPublisher<[Article], any Error> {
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
    
    override func searchArticles(query: String, categories: [String]?) -> AnyPublisher<[Article], Error> {
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
}
