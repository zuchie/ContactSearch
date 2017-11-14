//
//  Stack.swift
//  ContactsSearch
//
//  Created by Zhe Cui on 11/13/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

struct Stack<T> {
    var stack: [T] = []
    var isEmpty: Bool {
        return stack.isEmpty
    }
    var count: Int {
        return stack.count
    }
    
    mutating func push(_ element: T) {
        stack.append(element)
    }
    
    func peek() -> T? {
        return stack.last
    }
    
    @discardableResult mutating func pop() -> T? {
        guard !stack.isEmpty else { return nil }
        return stack.removeLast()
    }
    
    @discardableResult mutating func popLast(_ count: Int) -> [T]? {
        guard count <= self.count else { return nil }
        var popped: [T] = []
        
        for _ in 0 ..< count {
            popped.append(pop()!)
        }
        
        return popped
    }
}
