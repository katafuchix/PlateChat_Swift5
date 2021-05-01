//
//  Array+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation

extension Array {
    // 配列から重複する要素を除く
    func unique(predicate: @escaping (Element, Element) -> Bool) -> [Element] {
        var result: [Element] = []
        forEach { elm -> Void in
            guard !result.contains(where: { res -> Bool in
                return predicate(res, elm)
            }) else { return }
            result.append(elm)
        }
        return result
    }
}

extension Array where Element : Equatable  {

    mutating func remove(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
        }
    }

    mutating func replace(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
            insert(element, at: index)
        }
    }

    mutating func insertOrUpdate(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
            insert(element, at: index)
        } else {
            append(element)
        }
    }
}

extension Array {

    mutating func appendIfPossible(_ element: Element?) {
        guard let e = element else { return }
        self.append(e)
    }


    var lastIndex: Int {
        if self.count == 0 { return 0 }
        return self.count - 1
    }
}
