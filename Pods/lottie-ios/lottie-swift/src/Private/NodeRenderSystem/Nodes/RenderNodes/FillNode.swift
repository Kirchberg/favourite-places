//
//  FillNode.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/17/19.
//

import CoreGraphics
import Foundation

final class FillNodeProperties: NodePropertyMap, KeypathSearchable {
    var keypathName: String

    init(fill: Fill) {
        keypathName = fill.name
        color = NodeProperty(provider: KeyframeInterpolator(keyframes: fill.color.keyframes))
        opacity = NodeProperty(provider: KeyframeInterpolator(keyframes: fill.opacity.keyframes))
        type = fill.fillRule
        keypathProperties = [
            "Opacity": opacity,
            "Color": color,
        ]
        properties = Array(keypathProperties.values)
    }

    let opacity: NodeProperty<Vector1D>
    let color: NodeProperty<Color>
    let type: FillRule

    let keypathProperties: [String: AnyNodeProperty]
    let properties: [AnyNodeProperty]
}

final class FillNode: AnimatorNode, RenderNode {
    let fillRender: FillRenderer
    var renderer: NodeOutput & Renderable {
        return fillRender
    }

    let fillProperties: FillNodeProperties

    init(parentNode: AnimatorNode?, fill: Fill) {
        fillRender = FillRenderer(parent: parentNode?.outputNode)
        fillProperties = FillNodeProperties(fill: fill)
        self.parentNode = parentNode
    }

    // MARK: Animator Node Protocol

    var propertyMap: NodePropertyMap & KeypathSearchable {
        return fillProperties
    }

    let parentNode: AnimatorNode?
    var hasLocalUpdates: Bool = false
    var hasUpstreamUpdates: Bool = false
    var lastUpdateFrame: CGFloat?
    var isEnabled: Bool = true {
        didSet {
            fillRender.isEnabled = isEnabled
        }
    }

    func localUpdatesPermeateDownstream() -> Bool {
        return false
    }

    func rebuildOutputs(frame _: CGFloat) {
        fillRender.color = fillProperties.color.value.cgColorValue
        fillRender.opacity = fillProperties.opacity.value.cgFloatValue * 0.01
        fillRender.fillRule = fillProperties.type
    }
}
