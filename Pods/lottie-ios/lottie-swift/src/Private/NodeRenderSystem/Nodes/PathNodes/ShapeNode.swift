//
//  PathNode.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/16/19.
//

import CoreGraphics
import Foundation

final class ShapeNodeProperties: NodePropertyMap, KeypathSearchable {
    var keypathName: String

    init(shape: Shape) {
        keypathName = shape.name
        path = NodeProperty(provider: KeyframeInterpolator(keyframes: shape.path.keyframes))
        keypathProperties = [
            "Path": path,
        ]
        properties = Array(keypathProperties.values)
    }

    let path: NodeProperty<BezierPath>
    let keypathProperties: [String: AnyNodeProperty]
    let properties: [AnyNodeProperty]
}

final class ShapeNode: AnimatorNode, PathNode {
    let properties: ShapeNodeProperties

    let pathOutput: PathOutputNode

    init(parentNode: AnimatorNode?, shape: Shape) {
        pathOutput = PathOutputNode(parent: parentNode?.outputNode)
        properties = ShapeNodeProperties(shape: shape)
        self.parentNode = parentNode
    }

    // MARK: Animator Node

    var propertyMap: NodePropertyMap & KeypathSearchable {
        return properties
    }

    let parentNode: AnimatorNode?
    var hasLocalUpdates: Bool = false
    var hasUpstreamUpdates: Bool = false
    var lastUpdateFrame: CGFloat?
    var isEnabled: Bool = true {
        didSet {
            pathOutput.isEnabled = isEnabled
        }
    }

    func rebuildOutputs(frame: CGFloat) {
        pathOutput.setPath(properties.path.value, updateFrame: frame)
    }
}
