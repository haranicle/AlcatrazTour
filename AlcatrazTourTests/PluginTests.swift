//
//  PluginTests.swift
//  AlcatrazTour
//
//  Created by MTER on 2015/02/26.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import XCTest

class PluginTests: XCTestCase {

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
    
    func test_stringAsDate_worksFine() {
        var plugin = Plugin()
        XCTAssertEqual(1424887550, plugin.stringAsDate("2015-02-26T03:05:50Z").timeIntervalSince1970)
        XCTAssertEqual(0, plugin.stringAsDate("1970-01-01T09:00:00Z").timeIntervalSince1970)
        XCTAssertEqual(NSDate(timeIntervalSince1970: 0), plugin.stringAsDate("aaaaaaa"))
        XCTAssertEqual(NSDate(timeIntervalSince1970: 0), plugin.stringAsDate(""))
    }

}
