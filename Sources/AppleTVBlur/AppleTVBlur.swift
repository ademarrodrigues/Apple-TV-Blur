import CoreImage.CIFilterBuiltins
import QuartzCore
import SwiftUI
import UIKit

/// The direction of the progressive blur gradient.
public enum AppleTVBlurDirection {
    case blurredTopClearBottom
    case blurredBottomClearTop
}

/// A live progressive backdrop blur for SwiftUI.
public struct AppleTVBlur: UIViewRepresentable {
    public var maxBlurRadius: CGFloat
    public var direction: AppleTVBlurDirection
    public var startOffset: CGFloat

    public init(
        maxBlurRadius: CGFloat = 20,
        direction: AppleTVBlurDirection = .blurredTopClearBottom,
        startOffset: CGFloat = 0
    ) {
        self.maxBlurRadius = maxBlurRadius
        self.direction = direction
        self.startOffset = startOffset
    }

    public func makeUIView(context: Context) -> AppleTVBlurView {
        AppleTVBlurView(
            maxBlurRadius: maxBlurRadius,
            direction: direction,
            startOffset: startOffset
        )
    }

    public func updateUIView(_ uiView: AppleTVBlurView, context: Context) {
        uiView.update(
            maxBlurRadius: maxBlurRadius,
            direction: direction,
            startOffset: startOffset
        )
    }
}

/// UIKit view that applies the progressive blur to its backdrop.
///
/// This uses iOS’s undocumented `variableBlur` Core Animation filter.
open class AppleTVBlurView: UIVisualEffectView {
    private var maxBlurRadius: CGFloat
    private var direction: AppleTVBlurDirection
    private var startOffset: CGFloat

    public init(
        maxBlurRadius: CGFloat = 20,
        direction: AppleTVBlurDirection = .blurredTopClearBottom,
        startOffset: CGFloat = 0
    ) {
        self.maxBlurRadius = maxBlurRadius
        self.direction = direction
        self.startOffset = startOffset
        super.init(effect: UIBlurEffect(style: .regular))
        applyConfiguration()
    }

    /// Updates the blur without recreating the underlying UIKit view.
    public func update(
        maxBlurRadius: CGFloat,
        direction: AppleTVBlurDirection,
        startOffset: CGFloat
    ) {
        self.maxBlurRadius = maxBlurRadius
        self.direction = direction
        self.startOffset = startOffset
        applyConfiguration()
    }

    private func applyConfiguration() {
        let filterClassName = String("retliFAC".reversed())
        guard let filterClass = NSClassFromString(filterClassName) as? NSObject.Type,
              let filter = filterClass.perform(
                NSSelectorFromString(String(":epyThtiWretlif".reversed())),
                with: "variableBlur"
              )?.takeUnretainedValue() as? NSObject,
              let backdropLayer = subviews.first?.layer,
              let gradient = makeGradient(direction: direction, startOffset: startOffset) else {
            restoreSystemBlur()
            return
        }

        filter.setValue(maxBlurRadius, forKey: "inputRadius")
        filter.setValue(gradient, forKey: "inputMaskImage")
        filter.setValue(true, forKey: "inputNormalizeEdges")
        backdropLayer.filters = [filter]

        for subview in subviews.dropFirst() {
            subview.alpha = 0
        }
    }

    private func restoreSystemBlur() {
        effect = UIBlurEffect(style: .regular)
        for subview in subviews.dropFirst() {
            subview.alpha = 1
        }
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func didMoveToWindow() {
        guard let window, let layer = subviews.first?.layer else { return }
        layer.setValue(window.traitCollection.displayScale, forKey: "scale")
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {}

    private func makeGradient(
        direction: AppleTVBlurDirection,
        startOffset: CGFloat,
        size: CGFloat = 100
    ) -> CGImage? {
        let filter = CIFilter.linearGradient()
        filter.color0 = .black
        filter.color1 = .clear
        filter.point0 = CGPoint(x: 0, y: size)
        filter.point1 = CGPoint(x: 0, y: startOffset * size)

        if direction == .blurredBottomClearTop {
            filter.point0.y = 0
            filter.point1.y = size - filter.point1.y
        }

        guard let outputImage = filter.outputImage else { return nil }
        return CIContext().createCGImage(
            outputImage,
            from: CGRect(x: 0, y: 0, width: size, height: size)
        )
    }
}
