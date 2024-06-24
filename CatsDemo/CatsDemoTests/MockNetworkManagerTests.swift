//
//  MockNetworkManagerTests.swift
//  MockNetworkManagerTests
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import XCTest
@testable import CatsDemo_Dev

final class MockNetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    var session: MockURLSession!
    
    override func setUpWithError() throws {
        super.setUp()
        session = MockURLSession()
        networkManager = NetworkManager(session: session)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testExecuteRequestForURL() {
        
        guard let url = URL(string: "https://mockurl") else {
            fatalError("URL can't be empty")
        }
        
        let request = Request(path: "https://mockurl", method: .get, contentType: "application/json", headerParams: nil, type: .cats, body: nil)
        
        networkManager.execute(request: request, completion: { [weak self](result: (Result<[CatBreed], NetworkError>)) in
            if let sessionUrl = self?.session.lastURL {
                XCTAssert(sessionUrl == url)
            }
        })
        
    }
        
    func testExecuteDataTaskWithResumeCalled() {
        
        let dataTask = MockURLSessionDataTask()
        session.mockDataTask = dataTask
        
        let request = Request(path: "https://mockurl", method: .get, contentType: "application/json", headerParams: nil, type: .cats, body: nil)
        
        networkManager.execute(request: request, completion: { (result: (Result<[CatBreed], NetworkError>)) in
            
        })
        
        XCTAssert(dataTask.resumeWasCalled)
    }
}
