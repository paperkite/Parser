//
//  StubbedResponse.swift
//  Parser
//
//  Created by Will Townsend on 21/09/16.
//  Copyright © 2016 PaperKite. All rights reserved.
//

import Foundation

func stubbedResponse(filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    let bundle = Bundle(for: TestClass.self)
    if let url = bundle.url(forResource: filename, withExtension: "json") {
        return try? Data(contentsOf: url)
    }
    return nil
}
