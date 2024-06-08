//
//  APIServiceTests.swift
//  NewsAppTests
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import XCTest
@testable import NewsApp
import Combine

// Mock APIService to simulate network responses
class MockAPIService: APIService {
    override func fetchHeadlines(for country: String, categories: [String]?) -> AnyPublisher<[Article], Error> {
        let source = Source(name: "Test Source")
        let articles = [
            Article(
                title: "Mock Article",
                publishedAt: "2024-06-06T12:00:00Z",
                urlToImage: "https://test.com/image.jpg",
                source: source,
                description: "This is a mock article for testing.",
                url: "https://test.com"
            )
        ]
        
        // Simulate a successful network response with mock data
        return Just(articles)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class APIServiceTests: XCTestCase {
    var apiService: APIService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        // Use the MockAPIService instead of the real APIService
        apiService = MockAPIService()
        cancellables = []
    }

    override func tearDown() {
        apiService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchHeadlinesSuccess() {
        let expectation = self.expectation(description: "Fetch headlines successfully")
        var articles: [Article] = []

        apiService.fetchHeadlines(for: "us", categories: ["business"])
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
        XCTAssertEqual(articles.count, 1, "There should be one article")
        XCTAssertEqual(articles.first?.title, "Mock Article", "The title should match the mock data")
    }
}
