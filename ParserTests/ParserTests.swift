//
//  ParserTests.swift
//  ParserTests
//
//  Created by Walig Castain on 2/06/16.
//  Copyright © 2016 PaperKite. All rights reserved.
//

import XCTest
@testable import Parser

enum ContractType: String {
    case Employee = "employee"
    case Contractor = "contractor"
}

class Employee: 🔨 {
    
    let name: String
    let contractType: ContractType

    required init?(jsonDictionary: [String: AnyObject]) {
        
        let parser = Parser(dictionary: jsonDictionary)

        do {
            self.name = try parser.fetch("name")
            self.contractType = try parser.fetch("type") {  ContractType(rawValue: $0) }
            
        } catch let error {
            print(error)
            return nil
        }
    }

}

class Company: 🔨 {
    
    let id: String
    let name: String
    let age: Int
    let codingEnabled: Bool
    let coowner: String?
    let numberOfEmployee: Int
    let averageAgeEmployee: Int?
    let team: [Employee]
    let optionalTeam: [Employee]?
    let optionalTeamNested: [Employee]?

    required init?(jsonDictionary: [String: AnyObject]) {
        
        let parser = Parser(dictionary: jsonDictionary)
        
        do {
            self.id = try parser.fetch("id")
            self.name = try parser.fetch("name")
            self.age = try parser.fetch("age")
            self.codingEnabled = try parser.fetch("coding_enabled")
            self.coowner = try parser.fetchOptional("coowner")
            self.numberOfEmployee = try parser.fetch(["team","number_employee"])
            self.averageAgeEmployee = try parser.fetchOptional(["team", "average_age"])
            self.team = try parser.fetchArray(["team","list"]) { Employee(jsonDictionary: $0) }
            self.optionalTeam = try parser.fetchOptionalArray("optional_team") { Employee(jsonDictionary: $0) }
            self.optionalTeamNested = try parser.fetchOptionalArray(["optional_team_nested", "list"]) { Employee(jsonDictionary: $0) }

        } catch let error {
            print(error)
            return nil
        }
    }

}

class ParserTests: XCTestCase {

    /**
     Should be all parsed correctly
     */
    func testInitializer() {
        
        let data = stubbedResponse(filename: "companies")!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        
        if let company = Company(jsonDictionary: json) {
            XCTAssert(company.id == "2c16035c-9a28-42fc-86c0-e517c70798a3")
            XCTAssert(company.name == "PaperKite")
            XCTAssert(company.age == 8)
            XCTAssert(company.codingEnabled == true)
            XCTAssert(company.numberOfEmployee == 2)
            XCTAssert(company.averageAgeEmployee == 28)

            if let employeeOne: Employee = company.team[0], let employeeTwo: Employee = company.team[1] {
                XCTAssert(employeeOne.name == "paul")
                XCTAssert(employeeOne.contractType == .Contractor)

                XCTAssert(employeeTwo.name == "tom")
                XCTAssert(employeeTwo.contractType == .Employee)
            } else {
                XCTFail("Unable to assert employees")
            }
            
            if let employeeOne: Employee = company.optionalTeam![0], let employeeTwo: Employee = company.optionalTeam![1] {
                XCTAssert(employeeOne.name == "rebecca")
                XCTAssert(employeeOne.contractType == .Employee)
                
                XCTAssert(employeeTwo.name == "nate")
                XCTAssert(employeeTwo.contractType == .Contractor)
            } else {
                XCTFail("Unable to assert optional_team")
            }
            
            if let employeeOne: Employee = company.optionalTeamNested![0], let employeeTwo: Employee = company.optionalTeamNested![1] {
                XCTAssert(employeeOne.name == "patrick")
                XCTAssert(employeeOne.contractType == .Contractor)
                
                XCTAssert(employeeTwo.name == "andrew")
                XCTAssert(employeeTwo.contractType == .Employee)
            } else {
                XCTFail("Unable to assert optional_nested_team")
            }

        } else {
            XCTFail("fail to init Company")
        }
    }
    
    /**
     The age in the JSON is not a number but a string
     */
    func testWrongAgeTypeInJSON() {
        
        let data = stubbedResponse(filename: "companies-invalid-age")!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]

        let company = Company(jsonDictionary: json)
        XCTAssertNil(company, "Company should be nil, as age is a string in the JSON")
    }
    
    /**
     The coding_enabled in the JSON is not a number but a string
     */
    func testWrongBoolTypeInJSON() {
        
        let data = stubbedResponse(filename: "companies-invalid-coding")!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        
        let company = Company(jsonDictionary: json)
        XCTAssertNil(company, "Company should be nil, as coding_enabled is a string in the JSON")
    }
    
    /**
     Test optional employee array
     */
    func testOptionalEmployeeArrayBeingNilInJSON() {
        
        let data = stubbedResponse(filename: "companies-invalid-coding")!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        
        if let company = Company(jsonDictionary: json) {
            XCTAssert(company.id == "2c16035c-9a28-42fc-86c0-e517c70798a3")
            XCTAssert(company.name == "PaperKite")
            XCTAssert(company.age == 8)
            XCTAssert(company.codingEnabled == true)
            XCTAssert(company.numberOfEmployee == 2)
            XCTAssert(company.averageAgeEmployee == 28)

            if let employeeOne: Employee = company.team[0], let employeeTwo: Employee = company.team[1] {
                XCTAssert(employeeOne.name == "paul")
                XCTAssert(employeeOne.contractType == .Employee)
                
                XCTAssert(employeeTwo.name == "tom")
                XCTAssert(employeeTwo.contractType == .Contractor)
            } else {
                XCTFail("Unable to assert employees")
            }
            
            XCTAssertNil(company.optionalTeam)
            XCTAssertNil(company.optionalTeamNested)

        } else {
            XCTFail("fail to init Company")
        }
    }
    
    /**
     Test wrong enum type
     */
    func testOptionalEmployeeArrayBeingNilWithWrongEnumInJSON() {
        
        let data = stubbedResponse(filename: "companies-invalid-enum-value")!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        
        if let company = Company(jsonDictionary: json) {
            XCTAssert(company.id == "2c16035c-9a28-42fc-86c0-e517c70798a3")
            XCTAssert(company.name == "PaperKite")
            XCTAssert(company.age == 8)
            XCTAssert(company.codingEnabled == true)
            XCTAssert(company.numberOfEmployee == 2)
            XCTAssert(company.averageAgeEmployee == 28)
            
            if let employeeOne: Employee = company.team[0], let employeeTwo: Employee = company.team[1] {
                XCTAssert(employeeOne.name == "paul")
                XCTAssert(employeeOne.contractType == .Employee)
                
                XCTAssert(employeeTwo.name == "tom")
                XCTAssert(employeeTwo.contractType == .Contractor)
            } else {
                XCTFail("Unable to assert employees")
            }

            XCTAssertNil(company.optionalTeam)
            XCTAssertNil(company.optionalTeamNested)
            
        } else {
            XCTFail("fail to init Company")
        }
    }

}
