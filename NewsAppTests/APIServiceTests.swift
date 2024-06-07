//
//  APIServiceTests.swift
//  NewsAppTests
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import XCTest
@testable import NewsApp
import Combine

class APIServiceTests: XCTestCase {
    var apiService: APIService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        apiService = APIService()
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
    }
}
