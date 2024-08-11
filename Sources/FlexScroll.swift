import SwiftUI

///
/// Flexible ScrollView with soft sensitive setting.
/// It is focused more on pagination, it is great for pagination in both directions.
///
/// Better to use a Deque from swift-collections in your ForEach instead of
/// an array if you implement two-way pagination, it has a difficulty
/// inserting at the start of O(1).
///
/// **Direction**: in `horizontal` axis – `start` is left, `end` is right.
/// in `vertical` – `start` is up, `end` is down.
///
/// `offset` equal zero in middle *all* your ForEach.
/// Use `additionOffset` for reset offset
///
/// **Attension**:
///
/// Don't use `Direction.start` with
/// `loadParamOnStart` == `.beforeReach` and
/// `startInMiddle` == `false`,
///  *think about it*...
///
public struct FlexScrollView<Content: View>: View {
    private var queue = DispatchQueue.global(qos: .userInteractive)

    @State private var contentWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var loading = false

    private var moveOffsetRep: CGFloat = 0
    @State private var additionOffsetRep: CGFloat = 0

    private let axis: Axis.Set
    @Binding var moveOffset: CGFloat
    @Binding var additionOffset: CGFloat
    @Binding var goToMiddle: Bool
    private let startInMiddle: Bool
    private let goBackBeforeLoad: Bool
    private let load: (Direction) -> Void
    private let loadParamOnStart: LoadParameter
    private let loadParamOnEnd: LoadParameter
    private let content: Content

    public init(
        axis: Axis.Set = .vertical,
        offset: Binding<CGFloat>,
        additionOffset: Binding<CGFloat>,
        startInMiddle: Bool = false,
        goBackBeforeLoad: Bool = true,
        goToMiddle: Binding<Bool>? = nil,
        loadFunc: @escaping (Direction) -> Void = { _ in },
        loadParameterOnStart: LoadParameter = .underTension,
        loadParameterOnEnd: LoadParameter = .beforeReach,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis

        self._moveOffset = offset
        self._additionOffset = additionOffset

        if let goToMiddle {
            self._goToMiddle = goToMiddle
        } else {
            self._goToMiddle = .constant(false)
        }

        self.startInMiddle = startInMiddle
        self.goBackBeforeLoad = goBackBeforeLoad

        self.load = loadFunc
        self.loadParamOnStart = loadParameterOnStart
        self.loadParamOnEnd = loadParameterOnEnd

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

                            if goBackBeforeLoad {
                                let deltaWidth = newContentWidth - contentWidth

                                if deltaWidth > 0 {
                                    moveOffset += deltaWidth
                                }

                                additionOffset = moveOffset
                            }

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
                                   loadParamOnStart == .underTension {
                                    loading = true
                                    queue.async { load(.start) }
                                }

                                if moveOffset <= -contentWidth + additionWidthOffset,
                                   loadParamOnEnd == .underTension {
                                    loading = true
                                    queue.async { load(.end) }
                                }
                            } else {
                                if moveOffset >= contentHeight - additionHeightOffset,
                                   loadParamOnStart == .underTension {
                                    loading = true
                                    queue.async { load(.start) }
                                }

                                if moveOffset <= -contentHeight + additionHeightOffset,
                                   loadParamOnEnd == .underTension {
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
                                       loadParamOnEnd == .beforeReach {
                                        queue.async { load(.end) }
                                    } else if moveOffset > contentWidth - screenWidth,
                                              loadParamOnStart == .beforeReach {
                                        queue.async { load(.start) }
                                    }
                                } else {
                                    if moveOffset < -contentHeight + screenHeight,
                                       loadParamOnEnd == .beforeReach {
                                        queue.async { load(.end) }
                                    } else if moveOffset > contentHeight - screenHeight,
                                              loadParamOnStart == .beforeReach {
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
                .onChange(of: goToMiddle) { _ in
                    withAnimation {
                        moveOffset = 0
                    }

                    additionOffset = 0
                    goToMiddle = false
                }
        }
    }
}

public enum Direction: String {
    case start, end
}

public enum LoadParameter: String {
    case underTension, beforeReach
}
