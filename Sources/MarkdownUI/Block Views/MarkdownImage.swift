import SwiftUI

struct MarkdownImage: View {

    private let text: AttributedString
    private let url: URL

    @Environment(\.markdownStyle) private var style

    init(_ image: MarkdownBlock.Image) {
        self.text = image.text
        self.url = image.url
    }

    var body: some View {
        if url.scheme == "https" {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(style.image.cornerRadius)
            } placeholder: {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
            }
            .padding(.top, style.image.padding.top)
            .padding(.bottom, style.image.padding.bottom)
        } else {
            #if os(macOS)
            let bundleImage = style.image.bundle?.image(forResource: path(from: url))
            if let image = bundleImage ?? NSImage(contentsOfFile: path(from: url)) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(style.image.cornerRadius)
                    .padding(.top, style.image.padding.top)
                    .padding(.bottom, style.image.padding.bottom)
            }
            #else
            let bundleImage = UIImage(named: path(from: url), in: style.image.bundle, with: nil)
            if let image = bundleImage ?? UIImage(contentsOfFile: path(from: url)) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(style.image.cornerRadius)
                    .padding(.top, style.image.padding.top)
                    .padding(.bottom, style.image.padding.bottom)
            }
            #endif
        }
    }

    private func path(from: URL) -> String {
        var result: String
        if #available(iOS 16.0, macOS 13.0, *) {
            result = url.path(percentEncoded: false)
        } else {
            result = url.path
        }
        if let queryIndex = result.firstIndex(of: "?") {
            result = String(result[..<queryIndex])
        }
        return result
    }
}
