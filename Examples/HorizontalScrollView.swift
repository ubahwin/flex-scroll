import SwiftUI

struct HorizontalScrollView: View {
    @State private var goToMiddle = false
    @State private var offset: CGFloat = 0
    @State private var additionOffset: CGFloat = 0
    @State private var array: [Int] = [
        -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5
    ]

    var body: some View {
        ZStack {
            FlexScrollView(
                axis: .horizontal,
                offset: $offset,
                additionOffset: $additionOffset,
                startInMiddle: true,
                goBackBeforeLoad: false,
                goToMiddle: $goToMiddle,
                loadFunc: { direction in
                    for new in 6..<15 {
                        array.insert(-new, at: 0)
                        array.append(new)
                    }

                    print("\(direction) loaded")
                },
                loadParameterOnStart: .underTension,
                loadParameterOnEnd: .underTension
            ) {
                HStack {
                    ForEach(array.indices, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(.green)
                                .frame(width: 260)

                            Text(array[index].description)
                                .font(.title)
                                .bold()
                        }
                    }
                }
            }

            VStack {
                Button("Middle") {
                    goToMiddle = true
                }
                Spacer()
            }
        }
    }
}

#Preview {
    HorizontalScrollView()
}

struct MyComponent: View {
    @State private var internalValue: String
    @Binding var externalValue: String?

    private var isExternalBinding: Bool {
        externalValue != nil
    }

    init(externalValue: Binding<String?>? = nil) {
        self._externalValue = Binding(
            get: { externalValue?.wrappedValue },
            set: { newValue in
                if let binding = externalValue {
                    binding.wrappedValue = newValue
                } else {
                    // External binding is nil, do nothing
                }
            }
        )
        self._internalValue = State(initialValue: externalValue?.wrappedValue ?? "")
    }

    var body: some View {
        VStack {
            TextField("Enter text", text: bindingValue)
                .onChange(of: bindingValue.wrappedValue) { _ in
                    // Handle changes
                }
        }
    }

    private var bindingValue: Binding<String> {
        Binding<String>(
            get: {
                isExternalBinding ? (externalValue ?? "") : internalValue
            },
            set: { newValue in
                if isExternalBinding {
                    externalValue = newValue
                } else {
                    internalValue = newValue
                }
            }
        )
    }
}
