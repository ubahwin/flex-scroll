# FlexScroll

![](https://img.shields.io/badge/iOS-14%2B-green?logo=apple)
![](https://img.shields.io/badge/Swift%205.9-FA7343?style=flat&logo=swift&logoColor=white)

Flexible ScrollView with soft sensitive setting.
It is focused more on pagination, it is great for pagination in both directions.

<div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center; column-gap: 24px; row-gap: 20px;">
  <img src="https://github.com/user-attachments/assets/5fdeb187-308e-4145-981a-73b44282e774" style="height:400px;">
  <img src="https://github.com/user-attachments/assets/3b058c00-f790-4966-9001-a0e0f261a143" style="height:400px;">
</div>

> [!TIP]
> Better to use a [_Deque_ from swift-collections](https://github.com/apple/swift-collections/blob/main/Documentation/Deque.md) in your ForEach instead of
> an array if you implement two-way pagination, it has a difficulty
> inserting at the start of O(1).

## Simplest example

```swift
FlexScrollView {
    VStack {
        ForEach(0..<10) { _ in
            Rectangle()
                .fill(.green)
                .frame(height: 100)
        }
    }
}
```

## Params

##### axis

`.horizontal` or `.vertical` scrollview

##### offset and additionOffset

> [!NOTE]
> It is important to use them together

Use `offset` for observing position. `offset` equal zero in middle _all_ your ForEach.

```swift
@State private var offset: CGFloat = 0
@State private var additionOffset: CGFloat = 0

FlexScrollView(offset: $offset, additionOffset: $additionOffset)
```

if you want to change the `offset` and there were no problems later when scrolling, do:

```
offset = yourValue
additionOffset = offset
```

##### startInMiddle

It is better suited for horizontal scroll, where you need to scroll in both directions.

##### goBackBeforeLoad

When adding new elements to your ForEach, `offset` will shift to where you were, however, if you use horizontal scroll from the _start in the middle_, then this functionality may not work correctly, use `goBackBeforeLoad`.

##### goToMiddle

```swift
@State private var goToMiddle = false

Button("Middle") {
    goToMiddle = true
}
```

##### loadFunc

Your function for pagination where direction in `horizontal` axis – `start` is left, `end` is right; in `vertical` – `start` is up, `end` is down.

```swift
loadFunc: { direction in
    viewModel.load(to: direction)
}
```

##### loadParamOnStart and loadParamOnEnd

`underTension` – in order for pagination to work, you need to pull.

`beforeReach` – pagination will work before reaching the end of the list.

> [!NOTE]
> If you use `Direction.start` with `loadParamOnStart == .beforeReach` and `startInMiddle == false`, that you will receive a `load(start)` while you are at the top, since `.beforeReach` loads before reaching the very end, and you are already at the end

## Tools

- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [SwiftLint](https://github.com/realm/SwiftLint)
