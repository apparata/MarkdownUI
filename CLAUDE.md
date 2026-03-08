# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

```bash
swift build          # Build the package
swift test           # Run all tests
```

Linting uses SwiftLint with the config in `.swiftlint.yml` (Xcode reporter format).

## Architecture

MarkdownUI is a zero-dependency SwiftUI library that renders Markdown as native views. It supports iOS 15+, macOS 12+, and tvOS 15+.

### Two-phase design: Parse → Render

1. **`MarkdownDocument`** — Parses a Markdown string into an array of `MarkdownBlock` values. Uses Apple's `AttributedString(markdown:)` with `PresentationIntent` to identify block types. Parsing is throwing; store the document in `@State` to avoid re-parsing on every SwiftUI refresh.

2. **`Markdown<Content>`** — A SwiftUI view that renders a `MarkdownDocument`. Supports `lazy: Bool` for `LazyVStack` vs `VStack` rendering, and an optional `@ViewBuilder` closure for custom view injection via `<view tag="..." />` in the Markdown source.

### Block model

`MarkdownBlock` is an enum with cases: `header`, `paragraph`, `divider`, `blockquote`, `code`, `list`, `table`, `image`, `customView`. Each case holds a typed struct with the block's data. Lists support arbitrary nesting with mixed ordered/unordered sublists.

### Styling

`MarkdownStyle` is a struct with sub-styles for every block type (headers 1–6, paragraph, image, lists, blockquote, code, divider, table). Applied via the `.markdownStyle(_:)` view modifier, which propagates through SwiftUI's environment. All properties have sensible defaults.

### Source layout

- `Sources/MarkdownUI/Document Model/` — `MarkdownDocument` (parser) and `MarkdownBlock` (data model)
- `Sources/MarkdownUI/Block Views/` — Internal SwiftUI views for each block type
- `Sources/MarkdownUI/Markdown.swift` — Main public `Markdown` view
- `Sources/MarkdownUI/MarkdownStyle.swift` — Styling system
- `ExampleView.swift` — Usage example with custom view injection
