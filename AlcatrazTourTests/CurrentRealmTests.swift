//
//  CurrentRealmTests.swift
//  AlcatrazTour
//
//  Created by haranicle on 2015/08/16.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import XCTest
import RealmSwift

class CurrentRealmTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        CurrentRealm().realm.deleteAll()
    }

}
