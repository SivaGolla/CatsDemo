//
//  ACatDetailViewModelTests.swift
//  CatsDemoTests
//
//  Created by Venkata Sivannarayana Golla on 24/06/24.
//

import XCTest
@testable import CatsDemo_Dev

final class ACatDetailViewModelTests: XCTestCase {

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

    func testDetailViewModelParams() throws {
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
        
        let model = viewModel.catModels[2].model
        let detailViewModel = ACatDetailViewModel(model: model)
        
        XCTAssertFalse(detailViewModel.titleText.isEmpty)
        XCTAssertEqual(detailViewModel.titleText, model.name)
        
        XCTAssertFalse(detailViewModel.fullText.isEmpty)
        XCTAssertTrue(detailViewModel.linkText.contains(model.wikipediaURL ?? ""))
        
        XCTAssertFalse(detailViewModel.wikiLink.isEmpty)
        XCTAssertEqual(detailViewModel.wikiLink, model.wikipediaURL ?? "")
    }
    
    func testDetailViewImageDownload() throws {
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
        
        let model = viewModel.catModels[2].model
        let detailViewModel = ACatDetailViewModel(model: model)
        
        let imageExpectation = expectation(description: "fetch all cats and favs successful")
        var downloadedImage: UIImage? = nil
        detailViewModel.loadRemoteImage { image in
            downloadedImage = image
            imageExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(downloadedImage)
    }
}

extension ACatDetailViewModelTests: MockURLSessionDelegate {
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

