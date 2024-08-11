import SwiftUI

struct VerticalScrollView: View {
    @State private var goToMiddle = false
    @State private var moveOffset: CGFloat = 0
    @State private var addtionOffset: CGFloat = 0
    @State private var count = 15

    var body: some View {
        ZStack {
            FlexScrollView(
                axis: .vertical,
                offset: $moveOffset,
                additionOffset: $addtionOffset,
                startInMiddle: false,
                goToMiddle: $goToMiddle,
                loadFunc: { direction in
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

#Preview("VerticalScrollView") {
    VerticalScrollView()
}
