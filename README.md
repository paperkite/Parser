# Parser 🔨

A micro library to parse and create your object from a dictionary.

## Installation

### Carthage

To integrate Parser into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "paperkite/Parser" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `Parser.framework` into your Xcode project.

### Manually

If you prefer not to use either of the mentioned dependency managers, you can integrate Parser into your project manually.

---

## Usage

### Creating a model

```swift
import Parser

struct Company: 🔨 { // 🔨 or ParsableObject
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

// Wherever you receive JSON data:
let company = Parser(jsonDictionary: validJsonDictionary)

```

---

## Thanks
This library is heavily inspired by the work of [Khanlou](http://khanlou.com/2016/04/decoding-json/)
