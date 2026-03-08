# MarkdownUI

A SwiftUI library for rendering Markdown as native views — no web views, no external dependencies.

## Features

- Headers (levels 1–6), paragraphs, blockquotes, code blocks, dividers
- Ordered and unordered lists with arbitrary nesting (including mixed types)
- Tables with column alignment
- Images (remote URLs and local asset catalog)
- Inline formatting: **bold**, *italic*, `code`, ~~strikethrough~~, [links](https://example.com)
- Custom view injection via `<view tag="..." />` tags
- Lazy rendering support for long documents
- Fully customizable styling through SwiftUI environment

## Requirements

- Swift 5.9+
- iOS 15+ / macOS 12+ / tvOS 15+

## Installation

Add MarkdownUI as a Swift Package dependency:

```
https://github.com/nicklama/MarkdownUI
```

## Usage

### Basic

```swift
import MarkdownUI

struct ContentView: View {
    @State var document = try! MarkdownDocument("# Hello\n\nThis is **Markdown**.")

    var body: some View {
        ScrollView {
            Markdown(document, lazy: false)
                .padding()
        }
    }
}
```

### Custom Styling

```swift
Markdown(document, lazy: false)
    .markdownStyle(MarkdownStyle(
        header1: .init(
            padding: .init(top: 20, bottom: 8),
            font: .largeTitle.bold(),
            color: .blue
        ),
        code: .init(
            padding: .init(top: 10, bottom: 10),
            internalPadding: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
            cornerRadius: 12,
            font: .system(.caption).monospaced(),
            backgroundColor: .black.opacity(0.05)
        )
    ))
    .tint(.blue) // Link color
```

### Custom View Injection

Embed custom SwiftUI views inside your Markdown using `<view tag="..." />`:

```markdown
Here is a chart:

<view tag="myChart" />
```

```swift
Markdown(document, lazy: false) { tag in
    switch tag {
    case "myChart":
        MyChartView()
    default:
        EmptyView()
    }
}
```

### Lazy Rendering

For long documents, use `lazy: true` to render blocks in a `LazyVStack`:

```swift
Markdown(document, lazy: true)
```

## Supported Markdown Elements

| Element | Syntax |
|---|---|
| Headers | `# H1` through `###### H6` |
| Bold | `**text**` or `__text__` |
| Italic | `*text*` or `_text_` |
| Strikethrough | `~~text~~` |
| Inline code | `` `code` `` |
| Links | `[text](url)` |
| Images | `![alt](url)` |
| Unordered lists | `- item` |
| Ordered lists | `1. item` |
| Blockquotes | `> quote` |
| Code blocks | ` ```language ` |
| Tables | `\| col \| col \|` with alignment |
| Dividers | `---` |
| Custom views | `<view tag="name" />` |

## License

BSD Zero Clause License — see [LICENSE](LICENSE) for details.
