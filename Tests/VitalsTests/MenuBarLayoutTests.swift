import AppKit
import XCTest
@testable import Vitals

final class MenuBarLayoutTests: XCTestCase {
    func testStackedNetworkDisplayHasStableImageSizeAndTwoRows() {
        let expected = NetworkMenuBarDisplay.size
        XCTAssertLessThanOrEqual(expected.height, 22)
        XCTAssertLessThan(expected.width, 100)
        for rate in [0.0, 999, 1024, 1_023_990, 1_048_576, 1_073_741_824] {
            let image = NetworkMenuBarDisplay.image(download: rate, upload: 123)
            XCTAssertEqual(image.size, expected)
            XCTAssertTrue(image.isTemplate)
            let rows = NetworkMenuBarDisplay.rows(download: rate, upload: 123)
            XCTAssertEqual(rows.count, 2)
            XCTAssertTrue(rows[0].hasPrefix("↓ "))
            XCTAssertTrue(rows[1].hasPrefix("↑ "))
            let width = NSAttributedString(string: rows[0], attributes: [.font: NetworkMenuBarDisplay.font]).size().width
            XCTAssertLessThanOrEqual(width, expected.width)
            XCTAssertNotNil(image.tiffRepresentation)
        }
    }
    func testNetworkWidthAndUploadPositionStayStableAcrossUnits() {
        let values: [Double] = [0, 9, 99, 999, 1000, 1024, 10_240, 102_400, 1_023_990, 1_048_576, 1_073_741_824]
        let kind = WidgetKind.network
        var widths: [CGFloat] = []
        var arrowOffsets: [CGFloat] = []
        for value in values {
            var snapshot = Snapshot()
            snapshot.net.rxRate = value
            snapshot.net.txRate = 123
            let text = " " + kind.menuBarText(snapshot)
            let attributes: [NSAttributedString.Key: Any] = [.font: kind.menuBarFont]
            let width = NSAttributedString(string: text, attributes: attributes).size().width
            widths.append(width)
            let prefix = String(text.prefix(while: { $0 != "↑" }))
            arrowOffsets.append(NSAttributedString(string: prefix, attributes: attributes).size().width)
            XCTAssertLessThanOrEqual(width, kind.menuBarWidth)
        }
        XCTAssertLessThan((widths.max() ?? 0) - (widths.min() ?? 0), 0.01)
        XCTAssertLessThan((arrowOffsets.max() ?? 0) - (arrowOffsets.min() ?? 0), 0.01)
    }
}
