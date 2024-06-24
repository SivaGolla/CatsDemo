//
//  CatsViewModelTests.swift
//  CatsDemoTests
//
//  Created by Venkata Sivannarayana Golla on 24/06/24.
//

import XCTest
@testable import CatsDemo_Dev

final class CatsViewModelTests: XCTestCase {

    var session: MockURLSession!
    var viewModel: CatsViewModel!
    var group: DispatchGroup!
    
    override func setUpWithError() throws {
        super.setUp()
        session = MockURLSession()
        viewModel = CatsViewModel()
        
        group = DispatchGroup()
        viewModel.group = group
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchCats() throws {
        session.responseFileName = "FetchAllCatsResponse"
        UserSession.activeSession = session
        
        let catsExpectation = expectation(description: "fetch all cats successful")
        
        viewModel.group.notify(queue: .main) {
            catsExpectation.fulfill()
        }
        
        group.enter()
        viewModel.loadCatList()
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(viewModel.catModels.count > 0)
    }
    
    func testFetchMyFavCats() throws {
        session.responseFileName = "MyFavCats"
        UserSession.activeSession = session
        
        let group = DispatchGroup()
        viewModel.group = group
        let catsExpectation = expectation(description: "fetch my favourite cats successful")
        
        viewModel.group.notify(queue: .main) {
            catsExpectation.fulfill()
        }
        
        group.enter()
        viewModel.loadFavoriteCats()
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(viewModel.favCats.count > 0)
    }

}
