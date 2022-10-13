//
//  TeslawsomeTests.swift
//  TeslawsomeTests
//
//  Created by Ivaylo Gashev on 20.08.22.
//

import XCTest
@testable import Teslawesome

class TeslawsomeTests: XCTestCase {
    func testSHA256Hashing() {
        let exampleString = "26g10niEqbFSRbJhOAHMREkIHCuz4BoEwTBC94FBlHpQATn2DcqDDLrFptcCrjReTNQ6iopW7ubw5pQbmhVLn8"
        let hashedString = Utils.hashInSHA256(string: exampleString)
        XCTAssertEqual(hashedString, "5a67f88f01671e6add354ef324e9f88533564ed8e9e91dc3a6c098276ae0f690")
    }
    
    func testURLBase64Encoding() {
        let exampleString = "5a67f88f01671e6add354ef324e9f88533564ed8e9e91dc3a6c098276ae0f690"
        let encoded = Utils.encodeBase64URL(string: exampleString)
        XCTAssertEqual(encoded, "NWE2N2Y4OGYwMTY3MWU2YWRkMzU0ZWYzMjRlOWY4ODUzMzU2NGVkOGU5ZTkxZGMzYTZjMDk4Mjc2YWUwZjY5MA")
    }
}
