//
//  Parser.swift
//  Parser
//
//  Created by Walig Castain on 2/06/16.
//  Copyright © 2016 PaperKite. All rights reserved.
//

import Foundation

typealias 🔨 = ParsableObject

struct ParserError: ErrorType {
    let message: String
}

protocol ParsableObject {
    init?(jsonDictionary: [String: AnyObject])
}

public struct Parser {
    let dictionary: [String: AnyObject]?
    
    init(dictionary: [String: AnyObject]?) {
        self.dictionary = dictionary
    }
    
    func fetch<T>(key: String) throws -> T {
        return try self.fetch([key])
    }
    
    func fetch<T>(keys: [String]) throws -> T {
        
        guard keys.count > 0 else {
            throw ParserError(message: "No specified keys")
        }
        
        var currentDictionary: [String: AnyObject]? = self.dictionary
        
        for key in keys {
            
            // get the next dictionary or value
            let nextValue = currentDictionary?[key]
            
            // check if last key
            if keys.last == key {
                
                guard let fetched = nextValue else  {
                    throw ParserError(message: "The key \"\(key)\" was not found.")
                }
                
                guard let typed = fetched as? T else {
                    throw ParserError(message: "The key \"\(key)\" was not the right type. It had value \"\(fetched).\"")
                }
                
                return typed
            }
            
            // check if dictionary
            guard let nextDictionary = nextValue as? [String: AnyObject] else  {
                throw ParserError(message: "The key \"\(key)\" was not a dictionary.")
            }
            
            currentDictionary = nextDictionary
            
        }
        
        throw ParserError(message: "Unexpected error")
    }
    
    func fetchOptional<T>(key: String) throws -> T? {
        return try self.fetchOptional([key])
    }
    
    func fetchOptional<T>(keys: [String]) throws -> T? {
        
        guard keys.count > 0 else {
            throw ParserError(message: "No specified keys")
        }
        
        var currentDictionary: [String: AnyObject]? = self.dictionary
        
        for key in keys {
            
            // get the next dictionary or value
            let nextValue = currentDictionary?[key]
            
            // check if last key
            if keys.last == key {
                
                guard let fetched = nextValue else  {
                    return nil
                }
                
                guard let typed = fetched as? T else {
                    return nil
                }
                
                return typed
            }
            
            // check if dictionary
            guard let nextDictionary = nextValue as? [String: AnyObject] else  {
                return nil
            }
            
            currentDictionary = nextDictionary
            
        }
        
        return nil
    }
    
    func fetch<T, U>(key: [String], transformation: T -> U?) throws -> U {
        let fetched: T = try fetch(key)
        guard let transformed = transformation(fetched) else {
            throw ParserError(message: "The value \"\(fetched)\" at key \"\(key)\" could not be transformed.")
        }
        return transformed
    }

    func fetch<T, U>(key: String, transformation: T -> U?) throws -> U {
        return try self.fetch([key], transformation: transformation)
    }
    
    func fetchOptional<T, U>(key: [String], transformation: T -> U?) throws -> U? {
        return try self.fetchOptional(key, transformation: transformation)
    }
    
    func fetchOptional<T, U>(key: String, transformation: T -> U?) throws -> U? {
        return try self.fetchOptional(key).flatMap(transformation)
    }
    
    func fetchArray<T, U>(key: String, transformation: T -> U?) throws -> [U] {
        return try self.fetchArray([key], transformation: transformation)
    }
    
    func fetchArray<T, U>(key: [String], transformation: T -> U?) throws -> [U] {
        let fetched: [T] = try fetch(key)
        return fetched.flatMap(transformation)
    }
    
}
