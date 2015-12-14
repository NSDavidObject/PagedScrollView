//
//  SequenceHelpers.swift
//  Swift-Extensions
//
//  Created by David Elsonbaty on 12/12/15.
//  Copyright © 2015 David Elsonbaty. All rights reserved.
//

import Foundation

extension SequenceType {
    
    @warn_unused_result
    func allMatch(match: Generator.Element -> Bool) -> Bool {
        return !contains({ !match($0) })
    }
    @warn_unused_result
    func noneMatch(match: Generator.Element -> Bool) -> Bool {
        return !contains({ match($0) })
    }
    
    @warn_unused_result
    func count(match: Generator.Element -> Bool) -> Int {
        
        return reduce(0) { count, elem in
            count + Int(match(elem))
        }
    }
    @warn_unused_result
    func indicesOf(match: Generator.Element -> Bool) -> [Int] {
        
        var indices: [Int] = []
        for (idx, elem) in self.enumerate() {
            if match(elem) { indices.append(idx) }
        }
        
        return indices
    }
    
    @warn_unused_result
    func takeWhile(match: Generator.Element -> Bool) -> [Generator.Element] {
        
        var elements: [Generator.Element] = []
        forEachWhile(match) { elem in
            elements.append(elem)
        }
        
        return elements
    }
    @warn_unused_result
    func takeUntil(match: Generator.Element -> Bool) -> [Generator.Element] {
        
        var elements: [Generator.Element] = []
        forEachUntil(match) { elem in
            elements.append(elem)
        }
        
        return elements
    }
    
    @warn_unused_result
    func findElement(match: Generator.Element -> Bool) -> Generator.Element? {
        
        for element in self where match(element) {
            return element
        }
        
        return nil
    }
    
    /// - Note: Execution stops when the condition is met.
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    ///
    /// - Complexity: O(`self.count`)
    func forEachUntil(condition: Void -> Bool, body: Self.Generator.Element -> Void) {
        enumerateUntil(condition) { (_, elem) in body(elem) }
    }
    
    func forEachUntil(match: Generator.Element -> Bool, body: Generator.Element -> Void) {
        
        for element in self {
            
            if match(element) { break }
            body(element)
        }
    }
    
    /// - Note: When condition is met, `body` is called with element.
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    ///
    /// - Complexity: O(`self.count`)
    func forEachWhere(match: Generator.Element -> Bool, body: Self.Generator.Element -> Void) {
        
        for element in self where condition(element) {
            body(element)
        }
    }
    
    func forEachWhile(match: Generator.Element -> Bool, body: Generator.Element -> Void) {
        
        for element in self {
            
            if (!match(element)) {
                break
            }
            
            body(element)
        }
    }
    
    
    func enumerateUntil(condition: Void -> Bool, body: (Int, Self.Generator.Element) -> Void) {
        
        for (idx, element) in self.enumerate() {
            
            if condition() { break }
            body(idx, element)
        }
    }
}
