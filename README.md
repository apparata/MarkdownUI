# MarkdownUI

A SwiftUI library for rendering Markdown as native views — no web views, no external dependencies.

## Features

- Headers (levels 1–6), paragraphs, blockquotes, code blocks, dividers
- Ordered and unordered lists with arbitrary nesting (including mixed types)
- Tables with column alignment
- Images (remote URLs and local asset catalog)
- Inline formatting: **bold**, *italic*, `code`, ~~strikethrough~~, [links](https://example.com)
- Custom view injection via `<view>` tags with parameters and data payloads
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

Embed custom SwiftUI views inside your Markdown using `<view>` tags. Use the tag-only initializer for simple cases:

```markdown
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

#### Parameters

Pass HTML-style attributes to custom views. Use the `customView:` initializer to access them:

```markdown
<view tag="myChart" title="Sales Report" color="blue" />
```

```swift
Markdown(document, lazy: false, customView: { customView in
    switch customView.tag {
    case "myChart":
        MyChartView(
            title: customView.parameters["title"] ?? "Chart",
            color: customView.parameters["color"] ?? "gray"
        )
    default:
        EmptyView()
    }
})
```

#### Data Payloads

For larger payloads like JSON, use a non-self-closing tag. The content between the tags is available as `Data?`:

```markdown
<view tag="dataChart">[{"label": "Q1", "value": 42}, {"label": "Q2", "value": 58}]</view>
```

```swift
Markdown(document, lazy: false, customView: { customView in
    if customView.tag == "dataChart", let data = customView.content {
        let bars = try? JSONDecoder().decode([Bar].self, from: data)
        MyDataChart(bars: bars ?? [])
    }
})
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
| Custom views | `<view tag="name" />` or `<view tag="name">data</view>` |

## License

BSD Zero Clause License — see [LICENSE](LICENSE) for details.
