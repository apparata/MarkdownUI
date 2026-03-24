import SwiftUI
import Charts

struct ExampleView: View {

    @State var markdown = try! MarkdownDocument(rawMarkdown)

    var body: some View {
        ScrollView(.vertical) {
            Markdown(markdown, lazy: false, customView: { customView in
                switch customView.tag {
                case "myChart":
                    MyChart(title: customView.parameters["title"] ?? "Chart")
                case "dataChart":
                    DataChart(customView: customView)
                default:
                    EmptyView()
                }
            })
            .markdownStyle(MarkdownStyle())
            .tint(.blue)
            .padding()
        }
    }
}

struct MyChart: View {
    var title: String = "Chart"

    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            Chart {
                BarMark(
                    x: .value("Color", "Red"),
                    y: .value("Value", 10)
                )
                .foregroundStyle(.red)
                BarMark(
                    x: .value("Color", "Green"),
                    y: .value("Value", 12)
                )
                .foregroundStyle(.green)
                BarMark(
                    x: .value("Color", "Blue"),
                    y: .value("Value", 8)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

struct DataChart: View {
    var customView: MarkdownBlock.CustomView

    struct Bar: Decodable {
        let label: String
        let value: Double
    }

    var bars: [Bar] {
        guard let data = customView.content else { return [] }
        return (try? JSONDecoder().decode([Bar].self, from: data)) ?? []
    }

    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            Chart(bars, id: \.label) { bar in
                BarMark(
                    x: .value("Label", bar.label),
                    y: .value("Value", bar.value)
                )
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

// MARK: - Preview

#Preview {
    ExampleView()
}

// MARK: - Markdown Text

let attributedMarkdown = try! AttributedString(markdown: rawMarkdown)

let rawMarkdown = #"""
# Header 1

## Header 2

Here is a link: [Apple](https://apple.com). We should also try **bold** to see if it works. Not to mention _italic_ and I guess one more __bold__.

- This is a list item.
    - This is a nested list item.
    - This is also a nested list item. It is a bit longer, to see what happens if a list element occupies multiple lines.
    - Here's yet another nested item.
        - Twice as nested.
- This too, is a list item.
    - Nested list items are fun.

---

1. First of all, let's try a list item.
1. Secondly, this is also a list item. It is a bit longer, to see what happens if a list element occupies multiple lines.
    1. This is a nested item.
    2. Also a nested item.
        - Mixed unordered list here
        - One more item
1. Thirdly, here's another list item.

### Header 3

Let's try some `inline code` here, and maybe some ~~strikethrough~~ while we are at it.

> This is a blockquote. A blockquote is a typographic element used to set apart and visually distinguish a longer quotation or excerpt from the main text.

```swift
// Here's a code block
func fibonacci(n: Int) -> Int {
    var num1 = 0
    var num2 = 1
    for _ in 0 ..< n {
        let num = num1 + num2
        num1 = num2
        num2 = num
    }
    return num2
}
```

This text is before the separator.

---

This text is after the separator.

| Fruit     | Color  | Is it good? |
|-----------|--------|------------:|
| 🍌 Banana | Yellow | Yes         |
| 🍏 Apple  | Green  | Yes         |
| 🍋 Lemon  | Yellow | Not really  |

This paragraph is after the table.

Here's a remote image:

![Darth Remote](https://cached-images.bonnier.news/gcs/bilder/dn-mly/5b2cf962-3fa4-4c47-9c5c-2f409466106f.jpeg)

And here's a local image:

![Darth Local](darthvader)

Here's a custom view:

<view tag="myChart" title="Sales Data" />

Here's a data-driven chart with a JSON payload:

<view tag="dataChart">[{"label": "Q1", "value": 42}, {"label": "Q2", "value": 58}, {"label": "Q3", "value": 35}, {"label": "Q4", "value": 71}]</view>

This is just some text after the custom views.
"""#
