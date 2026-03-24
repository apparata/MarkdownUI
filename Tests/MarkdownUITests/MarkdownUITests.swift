import XCTest
@testable import MarkdownUI

final class MarkdownUITests: XCTestCase {
    func testExample() {
        XCTAssertEqual(true, true)
    }

    // MARK: - Custom View Parsing

    func testCustomViewBasicTag() throws {
        let doc = try MarkdownDocument(#"<view tag="myView" />"#)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }
        XCTAssertEqual(view.tag, "myView")
        XCTAssertTrue(view.parameters.isEmpty)
        XCTAssertNil(view.content)
    }

    func testCustomViewWithParameters() throws {
        let doc = try MarkdownDocument(#"<view tag="chart" title="Sales Report" color="blue" />"#)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }
        XCTAssertEqual(view.tag, "chart")
        XCTAssertEqual(view.parameters["title"], "Sales Report")
        XCTAssertEqual(view.parameters["color"], "blue")
        XCTAssertEqual(view.parameters.count, 2)
        XCTAssertNil(view.content)
    }

    func testCustomViewWithContent() throws {
        let json = #"{"series": "revenue", "year": 2024}"#
        let markdown = #"<view tag="chart">"# + json + "</view>"
        let doc = try MarkdownDocument(markdown)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }
        XCTAssertEqual(view.tag, "chart")
        let content = try XCTUnwrap(view.content)
        XCTAssertEqual(String(data: content, encoding: .utf8), json)
    }

    func testCustomViewWithParametersAndContent() throws {
        let json = #"{"key": "value"}"#
        let markdown = #"<view tag="widget" title="My Widget">"# + json + "</view>"
        let doc = try MarkdownDocument(markdown)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }
        XCTAssertEqual(view.tag, "widget")
        XCTAssertEqual(view.parameters["title"], "My Widget")
        let content = try XCTUnwrap(view.content)
        XCTAssertEqual(String(data: content, encoding: .utf8), json)
    }

    func testCustomViewContentIsDecodable() throws {
        let markdown = #"<view tag="data">{"name": "Alice", "score": 42}</view>"#
        let doc = try MarkdownDocument(markdown)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }

        struct Payload: Decodable {
            let name: String
            let score: Int
        }

        let content = try XCTUnwrap(view.content)
        let payload = try JSONDecoder().decode(Payload.self, from: content)
        XCTAssertEqual(payload.name, "Alice")
        XCTAssertEqual(payload.score, 42)
    }

    func testCustomViewSelfClosingNoContent() throws {
        let doc = try MarkdownDocument(#"<view tag="empty" />"#)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }
        XCTAssertNil(view.content)
    }

    func testCustomViewTagIsRequired() throws {
        // No tag attribute — should not produce a custom view block
        let doc = try MarkdownDocument(#"<view title="oops" />"#)
        let hasCustomView = doc.blocks.contains { if case .customView = $0 { return true }; return false }
        XCTAssertFalse(hasCustomView)
    }

    func testCustomViewAmongOtherBlocks() throws {
        let markdown = """
        # Title

        Some paragraph.

        <view tag="widget" count="5" />

        More text.
        """
        let doc = try MarkdownDocument(markdown)
        let customView = try XCTUnwrap(doc.blocks.first(where: { if case .customView = $0 { return true }; return false }))
        guard case .customView(let view) = customView else { return }
        XCTAssertEqual(view.tag, "widget")
        XCTAssertEqual(view.parameters["count"], "5")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
