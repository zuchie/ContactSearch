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
    
    @discardableResult mutating func pop() -> T {
        return stack.removeLast()
    }
    
    @discardableResult mutating func popLast(_ count: Int) -> [T] {
        var popped: [T] = []
        let total = self.count < count ? self.count : count
        
        for _ in 0 ..< total {
            popped.append(pop())
        }
        
        return popped
    }
}
