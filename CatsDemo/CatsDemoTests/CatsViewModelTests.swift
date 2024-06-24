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
    }
    
    func testFetchMyFavCats() throws {
        session.delegate = self
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
    
    func testFetchAllCatsWithFavs() throws {
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
    }
    
    func testDownloadAnImageOfACat() throws {
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
        
        let imageExpectation = expectation(description: "fetch all cats and favs successful")
        var downloadedImage: UIImage? = nil
        viewModel.image(at: IndexPath(row: 2, section: 0)) { image in
            downloadedImage = image
            imageExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(downloadedImage)
    }

    func testMarkACatAsFavourite() throws {
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
        
        let aViewModel = viewModel.catModels[2]
        let favExpectation = expectation(description: "mark a cat as favourite is successful")

        viewModel.itemsDidChange = {
            favExpectation.fulfill()
        }
        
        viewModel.toggleFavourite(favID: "\(aViewModel.favID)", catBreed: aViewModel.model, type: .update)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(viewModel.catModels[2].isFavorite)
    }
    
    func testMarkACatAsUnFavourite() throws {
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
        let favExpectation = expectation(description: "mark a cat as favourite is successful")

        viewModel.itemsDidChange = {
            favExpectation.fulfill()
        }
        
        viewModel.toggleFavourite(favID: "\(aViewModel.favID)", catBreed: aViewModel.model, type: .remove)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertFalse(viewModel.catModels[2].isFavorite)
    }
}

extension CatsViewModelTests: MockURLSessionDelegate {
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
