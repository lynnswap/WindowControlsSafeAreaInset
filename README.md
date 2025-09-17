# WindowControlsStateKit

A tiny SwiftUI helper to keep your UI clear of the new window control buttons introduced on iPadOS 26. It dynamically offsets your overlay content so buttons you place near the top‑leading corner don’t collide with the system’s window controls.

## Features
- Automatically manages a `WindowControlsStateModel` to keep overlays clear of window controls
- Handles iPadOS 26 window controls inset dynamically when available
- Simple SwiftUI API for overlay alignment and custom padding
- Graceful fallback on earlier OS/toolchains (applies only your extra leading padding)

## Requirements
- iOS 17.0+ (package platform)
- Dynamic window controls avoidance requires:
  - iPadOS 26.0+ at runtime, and
  - Swift 6.2+ toolchain at build time (for the new margins/corner adaptation APIs)

Building with older toolchains or running on earlier OS versions falls back to a regular overlay with your specified `extraLeading` padding.

## Quick Start
Import the module and wrap your overlay controls with the modifier. By default it targets the top‑leading corner.

```swift
import SwiftUI
import WindowControlsStateKit

struct ContentView: View {
    var body: some View {
        List {
            /* ... */
        }
        .windowControlsSafeAreaInset {
            Button("Done") { /* ... */ }
        }
    }
}
```

`windowControlsSafeAreaInset` internally installs a shared `WindowControlsStateModel` so every descendant overlay can read the latest control position. On iPadOS 26 with a Swift 6.2+ build, the overlay’s leading padding automatically reflects the horizontal inset of the system window controls. On earlier systems it behaves like a normal overlay plus your `extraLeading`.

## Limitations
- Dynamic avoidance requires both iPadOS 26+ and Swift 6.2+ at build time.
- Only the leading (left) inset for the window controls is handled; other safe‑area aspects remain unchanged.

## License
MIT — see `LICENSE` for details.
