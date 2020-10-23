//
//  ValueContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/30/19.
//

import CoreGraphics
import Foundation

/// A container for a node value that is Typed to T.
class ValueContainer<T>: AnyValueContainer {
    private(set) var lastUpdateFrame = CGFloat.infinity

    func setValue(_ value: Any, forFrame: CGFloat) {
        if let typedValue = value as? T {
            needsUpdate = false
            lastUpdateFrame = forFrame
            outputValue = typedValue
        }
    }

    func setNeedsUpdate() {
        needsUpdate = true
    }

    var value: Any {
        return outputValue as Any
    }

    var outputValue: T {
        didSet {
            needsUpdate = false
        }
    }

    init(_ value: T) {
        outputValue = value
    }

    fileprivate(set) var needsUpdate: Bool = true
}
