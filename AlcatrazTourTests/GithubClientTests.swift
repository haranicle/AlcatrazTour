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

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - Create URL
    func test_createRepoDetailUrl_worksFine() {
        let client = GithubClient()
        let actual = client.createRepoDetailUrl("https://github.com/onevcat/VVDocumenter-Xcode")
        XCTAssertEqual("https://api.github.com/repos/onevcat/VVDocumenter-Xcode", actual)
        
        XCTAssertEqual("aaa", client.createRepoDetailUrl("aaa"))
        XCTAssertEqual("", client.createRepoDetailUrl(""))
    }
    
    // MARK: - Request
    
    
    func test_requestPlugins_worksFine() {
        let client = GithubClient()
        
        func onSucceed(plugins:[Plugin]) {
            plugins.map{println("\($0.name)")}
        }
        
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
        }
        
        client.requestPlugins(onSucceed, onFailed: onFailed)
    }
    
    func test_requestRepoDetail_worksFine() {
        let client = GithubClient()
        
        var plugin = Plugin()
        plugin.url = "https://github.com/onevcat/VVDocumenter-Xcode"
        
        func onSucceed(plugin:Plugin?, pluginDetail:NSDictionary) {
            println(pluginDetail)
        }
        
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
        }
        
        client.requestRepoDetail(plugin
, onSucceed: onSucceed, onFailed: onFailed)
    }
    
    func test_reloadAllPlugins_worksFine() {
        let client = GithubClient()
        client.reloadAllPlugins()
    }

}
