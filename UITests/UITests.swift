import XCTest
import ViewInspector
import SwiftUI
@testable import FlexScroll

class ViewModel: ObservableObject {
    @Published var offset: CGFloat = 0
}

final class UITests: XCTestCase {
    @State var offset: CGFloat = 0
    @State var goToMiddle: Bool = false

    private var rectangleWidth: CGFloat = .infinity
    private var rectangleHeight: CGFloat = 260
    private var countRectangles = 16
    private var axis: Axis.Set = .vertical
    private var startInMiddle: Bool = false
    private var loadParameterOnStart: LoadParameter = .underTension
    private var loadParameterOnEnd: LoadParameter = .beforeReach

    private var rectangles: some View {
        ForEach(0..<countRectangles, id: \.self) { index in
            ZStack {
                Rectangle()
                    .fill(.red)
                    .frame(
                        width: self.rectangleWidth,
                        height: self.rectangleHeight
                    )

                Text(index.description)
                    .font(.title)
                    .bold()
            }
        }
    }

    private var flexScrollView: some View {
        FlexScrollView(
            axis: axis,
            offset: $offset,
            goToMiddle: $goToMiddle,
            startInMiddle: startInMiddle,
            loadFunc: { direction in
                print(direction, "loaded")
            },
            loadParameterOnStart: loadParameterOnStart,
            loadParameterOnEnd: loadParameterOnEnd
        ) {
            if self.axis == .horizontal {
                LazyHStack {
                    self.rectangles
                }
            } else {
                LazyVStack {
                    self.rectangles
                }
            }
        }
    }

    func testExample() throws {
        self.axis = .vertical
        self.startInMiddle = false
        self.loadParameterOnStart = .underTension
        self.loadParameterOnEnd = .beforeReach

        self.rectangleWidth = .infinity
        self.rectangleHeight = 260
        self.countRectangles = 16

        let forEachRectangles = try flexScrollView.inspect()
            .geometryReader()
            .lazyVStack()
            .forEach(0)

        for index in 0..<countRectangles {
            let text = try forEachRectangles
                .zStack(index)
                .text(1)
                .string()

            XCTAssertEqual(text, index.description)
        }
    }

    // TODO: tests paginations
}
