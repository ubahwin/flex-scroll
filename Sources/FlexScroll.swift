import SwiftUI

///
/// Flexible ScrollView with soft sensitive setting.
/// It is focused more on pagination, it is great for pagination in both directions.
///
/// **Direction**: in `horizontal` axis – `start` is left, `end` is right.
/// in `vertical` – `start` is up, `end` is down.
///
/// Better to use a Deque from swift-colletions in your ForEach instead of
/// an array if you implement two-way pagination, it has a difficulty 
/// inserting at the start of O(1).
///
/// Offset equal zero in middle *all* your ForEach.
///
/// **Attension**:
/// Don't check `Direction.start` with `.beforeReach` & `startInMiddle` == false,
/// *think about it*...
///
public struct FlexScrollView<Content: View>: View {
    private var queue = DispatchQueue.global(qos: .userInteractive)

    @State private var additionOffset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var loading = false

    private let axis: Axis.Set
    @Binding var moveOffset: CGFloat
    private let startInMiddle: Bool
    private let load: (Direction) -> Void
    private let loadParameterOnStart: LoadParameter
    private let loadParameterOnEnd: LoadParameter
    private let content: Content

    public init(
        axis: Axis.Set = .vertical,
        offset: Binding<CGFloat>,
        startInMiddle: Bool = false,
        loadFunc: @escaping (Direction) -> Void = { _ in },
        loadParameterOnStart: LoadParameter = .underTension,
        loadParameterOnEnd: LoadParameter = .beforeReach,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self._moveOffset = offset
        self.startInMiddle = startInMiddle
        self.load = loadFunc
        self.loadParameterOnStart = loadParameterOnStart
        self.loadParameterOnEnd = loadParameterOnEnd
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let maxWidthOffset = max(0, contentWidth - screenWidth / 2)
            let minWidthOffset = min(0, -contentWidth + screenWidth / 2)

            let maxHeightOffset = max(0, contentHeight - screenHeight / 2)
            let minHeightOffset = min(0, -contentHeight + screenHeight / 2)

            content
                // take ALL content size
                .background(GeometryReader { geometryIn in Color.clear
                    .onAppear {
                        if axis == .horizontal {
                            contentWidth = geometryIn.size.width / 2

                            if !startInMiddle {
                                moveOffset = contentWidth - screenWidth / 2
                                additionOffset = moveOffset
                            }
                        } else {
                            contentHeight = geometryIn.size.height / 2

                            if !startInMiddle {
                                moveOffset = contentHeight - screenHeight / 2
                                additionOffset = moveOffset
                            }
                        }
                    }
                    .onChange(of: geometryIn.size) { size in
                        // if was pagination then change content
                        // size and shift offset
                        if axis == .horizontal {
                            let newContentWidth = size.width / 2
                            let deltaWidth = newContentWidth - contentWidth

                            if deltaWidth > 0 {
                                moveOffset += deltaWidth
                            }

                            additionOffset = moveOffset

                            contentWidth = newContentWidth
                        } else {
                            // for pagination offset shift
                            let newContentHeight = size.height / 2
                            let deltaHeight = newContentHeight - contentHeight

                            if deltaHeight > 0 {
                                moveOffset += deltaHeight
                            }

                            additionOffset = moveOffset

                            contentHeight = newContentHeight
                        }
                    }
                })
                .offset(
                    x: axis == .horizontal ? moveOffset : 0,
                    y: axis == .horizontal ? 0 : moveOffset
                )
                .frame(
                    width: axis == .horizontal ? screenWidth : nil,
                    height: axis == .vertical ? screenHeight : nil
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if axis == .horizontal {
                                moveOffset = value.translation.width + additionOffset
                            } else {
                                moveOffset = value.translation.height + additionOffset
                            }

                            if loading {
                                return
                            }

                            let additionHeightOffset: CGFloat = 220
                            let additionWidthOffset: CGFloat = 90

                            if axis == .horizontal {
                                if moveOffset >= contentWidth - additionWidthOffset,
                                   loadParameterOnStart == .underTension {
                                    loading = true
                                    queue.async { load(.start) }
                                }

                                if moveOffset <= -contentWidth + additionWidthOffset,
                                   loadParameterOnEnd == .underTension {
                                    loading = true
                                    queue.async { load(.end) }
                                }
                            } else {
                                if moveOffset >= contentHeight - additionHeightOffset,
                                   loadParameterOnStart == .underTension {
                                    loading = true
                                    queue.async { load(.start) }
                                }

                                if moveOffset <= -contentHeight + additionHeightOffset,
                                   loadParameterOnEnd == .underTension {
                                    loading = true
                                    queue.async { load(.end) }
                                }
                            }
                        }
                        .onEnded { value in
                            let predictedEnd: CGFloat
                            let clampedOffset: CGFloat
                            if axis == .horizontal {
                                predictedEnd = value.predictedEndTranslation.width + additionOffset
                                clampedOffset = min(max(predictedEnd, minWidthOffset), maxWidthOffset)
                            } else {
                                predictedEnd = value.predictedEndTranslation.height + additionOffset
                                clampedOffset = min(max(predictedEnd, minHeightOffset), maxHeightOffset)
                            }

                            withAnimation(.easeOut(duration: 0.8)) {
                                moveOffset = clampedOffset
                            }

                            if !loading {
                                if axis == .horizontal {
                                    if moveOffset < -contentWidth + screenWidth,
                                       loadParameterOnEnd == .beforeReach {
                                        queue.async { load(.end) }
                                    } else if moveOffset > contentWidth - screenWidth,
                                              loadParameterOnStart == .beforeReach {
                                        queue.async { load(.start) }
                                    }
                                } else {
                                    if moveOffset < -contentHeight + screenHeight,
                                       loadParameterOnEnd == .beforeReach {
                                        queue.async { load(.end) }
                                    } else if moveOffset > contentHeight - screenHeight,
                                              loadParameterOnStart == .beforeReach {
                                        queue.async { load(.start) }
                                    }
                                }

                            }

                            additionOffset = moveOffset

                            if loading {
                                queue.asyncAfter(deadline: .init(uptimeNanoseconds: 500)) {
                                    loading = false
                                }
                            }
                        }
                )
        }
    }

    private func goToMiddle() {
        withAnimation(.easeOut(duration: 0.6)) {
            moveOffset = 0
        }

        additionOffset = 0
    }
}

struct GoToMiddleModifier: ViewModifier {
    @Binding var trigger: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { newValue in
                if newValue {
                    action()
                    trigger = false
                }
            }
    }
}

extension FlexScrollView {
    func middle(_ trigger: Binding<Bool>) -> some View {
        self.modifier(
            GoToMiddleModifier(trigger: trigger, action: goToMiddle)
        )
    }

    func pagination(
        loadParamOnStart: LoadParameter = .underTension,
        loadParamOnEnd: LoadParameter = .beforeReach,
        action: (Direction) -> Void
    ) -> some View {
        self
    }
}

public enum Direction: String {
    case start, end
}

public enum LoadParameter: String {
    case underTension, beforeReach
}

struct HorizontalScrollView: View {
    @State private var goToMiddle = false
    @State private var moveOffset: CGFloat = 0
    @State private var count = 15

    var body: some View {
        ZStack {
            FlexScrollView(
                axis: .horizontal,
                offset: $moveOffset,
                loadFunc: { direction in
                    count += 10
                    print("\(direction) loaded")
                },
                loadParameterOnStart: .underTension,
                loadParameterOnEnd: .beforeReach
            ) {
                HStack {
                    ForEach(0..<count, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(.green)
                                .frame(width: 260)

                            Text(index.description)
                                .font(.title)
                                .bold()
                        }
                    }
                }
            }
            .middle($goToMiddle)

            VStack {
                Button("Middle") {
                    goToMiddle = true
                }
                Spacer()
            }
        }
    }
}

struct VerticalScrollView: View {
    @State private var goToMiddle = false
    @State private var moveOffset: CGFloat = 0
    @State private var count = 15

    var body: some View {
        ZStack {
            FlexScrollView(
                axis: .vertical,
                offset: $moveOffset,
                startInMiddle: false,
                loadFunc: { direction in
                    count += 10
                    print("\(direction) loaded")
                }
            ) {
                VStack {
                    ForEach(0..<count, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(.green)
                                .frame(height: 260)

                            Text(index.description)
                                .font(.title)
                                .bold()
                        }
                    }
                }
            }

            VStack {
                Button("add") {
                    count += 10
                }
                Text(moveOffset.description)
                Slider(value: $moveOffset, in: -10000...10000)
                Spacer()
            }
        }
    }
}

#Preview("HorizontalScrollView") {
    HorizontalScrollView()
}

#Preview("VerticalScrollView") {
    VerticalScrollView()
}
