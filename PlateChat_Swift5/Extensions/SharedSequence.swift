//
//  SharedSequence.swift
//  PlateChat
//
//  Created by cano on 2018/11/26.
//  Copyright © 2018 deskplate. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension SharedSequence {

    /// split result to E and Error
    ///
    /// - Parameter result: Driver<Result<E>>
    /// - Returns: Driver<User>, Driver<Error>
    static func split(result: Driver<Result<Element>>) -> (response: Driver<Element>, error: Driver<Error>) {
        let responseDriver = result.flatMap { result -> Driver<Element> in
            switch result {
            case .succeeded(let response):
                return Driver.just(response)
            case .failed:
                return Driver.empty()
            } }
        let errorDriver = result.flatMap { result -> Driver<Error> in
            switch result {
            case .succeeded:
                return Driver.empty()
            case .failed(let error):
                return Driver.just(error)
            } }
        return (responseDriver, errorDriver)
    }
}

extension SharedSequence where Element: EventConvertible {
    /**
     Returns an observable sequence containing only next elements from its input
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     */
    public func elements() -> SharedSequence<SharingStrategy, Element.Element> {
        return filter { $0.event.element != nil }
            .map { $0.event.element! }
    }

    /**
     Returns an observable sequence containing only error elements from its input
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     */
    public func errors() -> SharedSequence<SharingStrategy, Swift.Error> {
        return filter { $0.event.error != nil }
            .map { $0.event.error! }
    }
}
