//
//  GithubClientTests.swift
//  AlcatrazTour
//
//  Created by MTER on 2015/02/24.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import XCTest

class GithubClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Create URL
    
    func test_createRepoDetailUrl_worksFine() {
        let client = GithubClient()
        let actual1 = client.createRepoDetailUrl("https://github.com/onevcat/VVDocumenter-Xcode")
        XCTAssertEqual("https://api.github.com/repos/onevcat/VVDocumenter-Xcode", actual1)
        
        let actual2 = client.createRepoDetailUrl("https://github.com/StefanLage/XQuit/")
        XCTAssertEqual("https://api.github.com/repos/StefanLage/XQuit", actual2)
        
        let actual3 = client.createRepoDetailUrl("https://github.com/StefanLage/XQuit.git")
        XCTAssertEqual("https://api.github.com/repos/StefanLage/XQuit", actual2)
        
        let actual4 = client.createRepoDetailUrl("https://github.com/StefanLage/XQuit.git/")
        XCTAssertEqual("https://api.github.com/repos/StefanLage/XQuit", actual4)
        
        XCTAssertEqual("aaa", client.createRepoDetailUrl("aaa"))
        XCTAssertEqual("", client.createRepoDetailUrl(""))
    }
    
    // MARK: - Request
    
    func test_requestPlugins_worksFine() {
        let expectation:XCTestExpectation = self.expectationWithDescription(__FUNCTION__)
        
        let client = GithubClient()
        
        let onSucceed = {(plugins:[Plugin]) -> Void in
            plugins.map{print("\($0.name)")}
            expectation.fulfill()
        }
        
        let onFailed = {(request:NSURLRequest?, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
            print("request = \(request)")
            print("response = \(response)")
            print("responseData = \(responseData)")
            print("error = \(error?.description)")
            expectation.fulfill()
        }
        
        client.requestPlugins(onSucceed, onFailed: onFailed)
        
        self.waitForExpectationsWithTimeout(3 , handler: nil)
    }
    
    func test_requestRepoDetail_worksFine() {
        let expectation:XCTestExpectation = self.expectationWithDescription(__FUNCTION__)
        
        let client = GithubClient()
        
        var plugin = Plugin()
        plugin.url = "https://github.com/XVimProject/XVim"
        
        let onSucceed = {(plugin:Plugin?, pluginDetail:NSDictionary) -> Void in
            NSLog("pluginDetail = \(pluginDetail)")
            expectation.fulfill()
        }
        
        let onFailed = {(request:NSURLRequest?, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
            print("request = \(request)")
            print("response = \(response)")
            print("responseData = \(responseData)")
            print("error = \(error?.description)")
            expectation.fulfill()
        }
        
        client.requestRepoDetail(client.oAuthToken()!, plugin: plugin
, onSucceed: onSucceed, onFailed: onFailed)
        self.waitForExpectationsWithTimeout(5 , handler: nil)
    }
    
    func test_reloadAllPlugins_worksFine() {
        let expectation:XCTestExpectation = self.expectationWithDescription(__FUNCTION__)
        
        let client = GithubClient()
        client.reloadAllPlugins({error in
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(30 , handler: nil)
    }
    
    func test_starRepository_worksFine() {
        let expectation:XCTestExpectation = self.expectationWithDescription(__FUNCTION__)
        
        let onSucceed = {() -> Void in
            expectation.fulfill()
            XCTAssert(true, "star succeed")
        }
        
        let onFailed = {(request:NSURLRequest?, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
            print("request = \(request)")
            print("response = \(response)")
            print("responseData = \(responseData)")
            print("error = \(error?.description)")
            expectation.fulfill()
            XCTAssert(true, "star failed")
        }
        
        let client = GithubClient()
        client.starRepository(client.oAuthToken()!, isStarring: true, owner: "haranicle", repositoryName: "sandbox", onSucceed: onSucceed, onFailed: onFailed);
        self.waitForExpectationsWithTimeout(30 , handler: nil)
    }

}
