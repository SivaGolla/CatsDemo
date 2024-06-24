//
//  ACatViewModelTests.swift
//  CatsDemoTests
//
//  Created by Venkata Sivannarayana Golla on 24/06/24.
//

import XCTest
@testable import CatsDemo_Dev

final class ACatViewModelTests: XCTestCase {

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

    func testViewModelParams() throws {
        session.delegate = self
        UserSession.activeSession = session
        
        let catsExpectation = expectation(description: "fetch all cats successful")
        
        viewModel.group.notify(queue: .main) {
            catsExpectation.fulfill()
        }
        
        group.enter()
        viewModel.loadCatList()
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(viewModel.catModels.count > 0)
        
        let aViewModel = viewModel.catModels[2]
        XCTAssertFalse(aViewModel.name.isEmpty)
        XCTAssertFalse(aViewModel.isFavorite)
        XCTAssertTrue(aViewModel.favID == 0)
    }
    
    func testViewModelFavCat() throws {
        session.delegate = self
        UserSession.activeSession = session
        
        let catsExpectation = expectation(description: "fetch all cats and favs successful")
        
        viewModel.itemsDidChange = {
            catsExpectation.fulfill()
        }
        
        viewModel.fetchAllCatsWithFavs()
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(viewModel.catModels.count > 0)
        XCTAssert(viewModel.favCats.count > 0)
        
        let aViewModel = viewModel.catModels[1]
        XCTAssertFalse(aViewModel.name.isEmpty)
        XCTAssertTrue(aViewModel.isFavorite)
        XCTAssertTrue(aViewModel.favID > 0)
    }
}

extension ACatViewModelTests: MockURLSessionDelegate {
    func resourceName(for path: String, httpMethod: String) -> String {
        if path.contains("breeds") {
            return "FetchAllCatsResponse"
        }
        
        if path.contains("favourites") {
            if httpMethod == RequestMethod.get.rawValue {
                return "MyFavCats"
            }
            
            if httpMethod == RequestMethod.post.rawValue || httpMethod == RequestMethod.del.rawValue {
                return "FavResponse"
            }
        }
        
        return ""
    }
}
