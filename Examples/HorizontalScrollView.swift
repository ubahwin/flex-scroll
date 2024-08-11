import SwiftUI

struct HorizontalScrollView: View {
    @State private var goToMiddle = false
    @State private var offset: CGFloat = 0
    @State private var addtionOffset: CGFloat = 0
    @State private var array: [Int] = [
        -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5
    ]

    var asd: some View {
        FlexScrollView(
            offset: $offset,
            additionOffset: $addtionOffset
        ) {
            VStack {
                ForEach(0..<10) { _ in
                    Rectangle()
                        .fill(.green)
                        .frame(height: 260)
                }
            }
        }
    }

    var body: some View {
        asd
//        ZStack {
//            FlexScrollView(
//                axis: .horizontal,
//                offset: $moveOffset,
//                additionOffset: $addtionOffset,
//                startInMiddle: true,
//                goBackBeforeLoad: false,
//                goToMiddle: $goToMiddle,
//                loadFunc: { direction in
//                    for new in 6..<15 {
//                        array.insert(-new, at: 0)
//                        array.append(new)
//                    }
//
//                    print("\(direction) loaded")
//                },
//                loadParameterOnStart: .underTension,
//                loadParameterOnEnd: .underTension
//            ) {
//                HStack {
//                    ForEach(array.indices, id: \.self) { index in
//                        ZStack {
//                            Rectangle()
//                                .fill(.green)
//                                .frame(width: 260)
//
//                            Text(array[index].description)
//                                .font(.title)
//                                .bold()
//                        }
//                    }
//                }
//            }
//
//            VStack {
//                Button("Middle") {
//                    goToMiddle = true
//                }
//                Spacer()
//            }
//        }
    }
}

#Preview {
    HorizontalScrollView()
}
