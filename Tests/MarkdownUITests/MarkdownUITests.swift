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

    // MARK: - Table Parsing

    private func firstTable(in markdown: String) throws -> MarkdownBlock.Table {
        let doc = try MarkdownDocument(markdown)
        let block = try XCTUnwrap(doc.blocks.first(where: { if case .table = $0 { return true }; return false }))
        guard case .table(let table) = block else {
            XCTFail("Expected a table block")
            fatalError()
        }
        return table
    }

    private func cellText(_ table: MarkdownBlock.Table) -> [[String]] {
        table.rows.map { $0.cells.map { String($0.text.characters) } }
    }

    func testTable() throws {
        let table = try firstTable(in: """
        | A | B |
        |---|---|
        | 1 | 2 |
        | 3 | 4 |
        """)
        XCTAssertEqual(table.columns.count, 2)
        XCTAssertEqual(cellText(table), [["A", "B"], ["1", "2"], ["3", "4"]])
        XCTAssertTrue(table.rows[0].isHeader)
        XCTAssertFalse(table.rows[1].isHeader)
    }

    func testTableWithEmptyCellInTheMiddle() throws {
        let table = try firstTable(in: """
        | A | B | C |
        |---|---|---|
        | 1 |   | 3 |
        """)
        XCTAssertEqual(cellText(table), [["A", "B", "C"], ["1", "", "3"]])
    }

    func testTableWithEmptyCellFirst() throws {
        let table = try firstTable(in: """
        | A | B |
        |---|---|
        |   | 2 |
        """)
        XCTAssertEqual(cellText(table), [["A", "B"], ["", "2"]])
    }

    func testTableWithEmptyCellLast() throws {
        let table = try firstTable(in: """
        | A | B | C |
        |---|---|---|
        | 1 | 2 |   |
        """)
        XCTAssertEqual(cellText(table), [["A", "B", "C"], ["1", "2", ""]])
    }

    func testTableWithEmptyHeaderCell() throws {
        let table = try firstTable(in: """
        | A |   | C |
        |---|---|---|
        | 1 | 2 | 3 |
        """)
        XCTAssertEqual(cellText(table), [["A", "", "C"], ["1", "2", "3"]])
    }

    func testTableWithEntirelyEmptyRow() throws {
        let table = try firstTable(in: """
        | A | B |
        |---|---|
        | 1 | 2 |
        |   |   |
        | 5 | 6 |
        """)
        XCTAssertEqual(cellText(table), [["A", "B"], ["1", "2"], ["", ""], ["5", "6"]])
    }

    func testTableRowsAndCellsHaveUniqueIDs() throws {
        let table = try firstTable(in: """
        | A |   | C |
        |---|---|---|
        | 1 |   |   |
        |   |   |   |
        |   | 2 | 3 |
        """)
        XCTAssertEqual(table.rows.count, 4)
        XCTAssertEqual(Set(table.rows.map(\.id)).count, table.rows.count)
        for row in table.rows {
            XCTAssertEqual(Set(row.cells.map(\.id)).count, row.cells.count)
        }
    }

    func testTableRowsAndCellsAreIndexedInOrder() throws {
        let table = try firstTable(in: """
        | A |   | C |
        |---|---|---|
        |   | 2 |   |
        | 4 |   | 6 |
        """)
        XCTAssertEqual(table.rows.map(\.index), [0, 1, 2])
        for row in table.rows {
            XCTAssertEqual(row.cells.map(\.index), [0, 1, 2])
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
