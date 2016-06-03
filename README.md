# Parser 🔨 - WORK IN PROGRESS
A micro library to parse and create your object from a dictionary.

## Installation

### CocoaPods

To integrate Parser into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'xxxxxxx'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

To integrate Parser into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "xxxxx/xxxxxxx"
```

Run `carthage update` to build the framework and drag the built `Parser.framework` into your Xcode project.

### Manually

If you prefer not to use either of the mentioned dependency managers, you can integrate Parser into your project manually.

---

## Usage

### Creating a model

```swift
import Parser

struct Company: 🔨 { // 🔨 or Parsable
    let id: Int
    let name: String
    let supportPhoneNumber: String?
    let ownership: Ownership
    let hasStore: Bool
    let nextOpen: OpeningHours
    let employees: [String]

    required init?(jsonDictionary: [String: AnyObject]) {
        
        let parser = Parser(dictionary: jsonDictionary)
        
        do {
            self.id = try parser.fetch("id")
            self.name = try parser.fetch(["detail", "site_name"]) // Parse nested objects
            self.supportPhoneNumber = try parser.fetchOptional("support_phone_number")
            self.ownership = try parser.fetch("ownership") { Ownership(rawValue: $0) }
            self.hasStore = try parser.fetch("has_store")
            self.nextOpen = try parser.fetch("next_open") { OpeningHours(jsonDictionary: $0) }
            self.hasStore = try parser.fetchArray("employees")
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
