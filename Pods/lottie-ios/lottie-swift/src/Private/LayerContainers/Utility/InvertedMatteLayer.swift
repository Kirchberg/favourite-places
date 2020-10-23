//
//  InvertedMatteLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/28/19.
//

import Foundation
import QuartzCore

/**
 A layer that inverses the alpha output of its input layer.

 WARNING: This is experimental and probably not very performant.
 */
final class InvertedMatteLayer: CALayer, CompositionLayerDelegate {
    let inputMatte: CompositionLayer?
    let wrapperLayer = CALayer()

    init(inputMatte: CompositionLayer) {
        self.inputMatte = inputMatte
        super.init()
        inputMatte.layerDelegate = self
        anchorPoint = .zero
        bounds = inputMatte.bounds
        setNeedsDisplay()
    }

    override init(layer: Any) {
        guard let layer = layer as? InvertedMatteLayer else {
            fatalError("init(layer:) wrong class.")
        }
        inputMatte = nil
        super.init(layer: layer)
    }

    func frameUpdated(frame _: CGFloat) {
        setNeedsDisplay()
        displayIfNeeded()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        guard let inputMatte = inputMatte else { return }
        guard let fillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0, 0, 0, 1])
        else { return }
        ctx.setFillColor(fillColor)
        ctx.fill(bounds)
        ctx.setBlendMode(.destinationOut)
        inputMatte.render(in: ctx)
    }
}
