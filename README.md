<img width="4156" height="2246" alt="mock" src="https://github.com/user-attachments/assets/84414be4-44dc-49e4-8030-b056a6580fd5" />
# Apple-TV-Blur

An iOS SwiftUI package for Apple TV-style progressive backdrop blur. Place the
effect over scrolling content to create a soft transition from blurred to clear.

## Requirements

- iOS 13+
- Swift 5.9+
- Xcode 15+

## Installation

Add this repository as a Swift Package dependency in Xcode, then import
`AppleTVBlur`.

## Usage

```swift
import SwiftUI
import AppleTVBlur

struct ContentView: View {
    var body: some View {
        ScrollView {
            // Your scrolling content
        }
        .overlay(alignment: .top) {
            AppleTVBlur(maxBlurRadius: 28)
                .frame(height: 160)
                .allowsHitTesting(false)
        }
    }
}
```

Use `.blurredBottomClearTop` for the inverse transition:

```swift
AppleTVBlur(
    maxBlurRadius: 24,
    direction: .blurredBottomClearTop
)
.frame(height: 160)
```

## API

- `maxBlurRadius`: maximum blur radius, default `20`.
- `direction`: `.blurredTopClearBottom` or `.blurredBottomClearTop`.
- `startOffset`: shifts where the gradient begins. A small negative value such
  as `-0.1` can hide a visible seam at the sharp edge.

## How it works

The package wraps `UIVisualEffectView`, creates a Core Image gradient mask, and
applies that mask to the backdrop layer’s blur radius. The result is a live blur
of the content behind the view rather than a captured screenshot.

The SwiftUI wrapper updates the existing UIKit view when its parameters change,
so it can be driven by state without recreating the view. If the progressive
filter or its gradient cannot be created, the view restores a regular system
blur instead of failing or becoming transparent.

## Platform note

The progressive blur relies on iOS’s undocumented `variableBlur` Core Animation
filter. Apple may change or remove it in a future release, and its use may carry
App Store review risk. The package automatically falls back to a regular
`UIBlurEffect` when the progressive filter is unavailable. Test every supported
iOS version before shipping.

## Contributing

Keep changes focused, document public API changes, and test on a physical device
when changing rendering behavior. Bug reports should include the iOS version,
device, and a minimal reproduction.

## License

MIT. See [LICENSE](LICENSE).
