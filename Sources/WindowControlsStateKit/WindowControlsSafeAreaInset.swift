// The Swift Programming Language
// https://docs.swift.org/swift-book
#if os(iOS)
import SwiftUI

private struct WindowControlsSafeAreaInsetModifier<Overlay: View>: ViewModifier {
    @Environment(\.windowControlsStateModel) private var environmentModel
    @State private var fallbackModel: WindowControlsStateModel?

    let alignment: Alignment
    let extraLeading: CGFloat
    let overlay: () -> Overlay

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if let model = environmentModel ?? fallbackModel {
                content
                    .overlay(alignment: alignment) {
                        overlay()
                            .padding(.leading, model.minX + extraLeading)
                            .opacity(model.installed ? 1 : 0)
                            .animation(.default, value: model.minX)
                    }
                    .background(
                        ContainerReader(model: model)
                    )
            }else{
                content
                    .background(
                        Color.clear
                            .onAppear {
                                if fallbackModel == nil {
                                    fallbackModel = WindowControlsStateModel()
                                }
                            }
                    )
            }
        }else{
            content
                .overlay(alignment: alignment) {
                    overlay()
                        .padding(.leading, extraLeading)
                }
        }
    }
}

public extension View {
    func windowControlsSafeAreaInset<Overlay: View>(
        alignment: Alignment = .topLeading,
        extraLeading: CGFloat = 0,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) -> some View {
        self.modifier(
            WindowControlsSafeAreaInsetModifier(
                alignment: alignment,
                extraLeading: extraLeading,
                overlay: overlay
            )
        )
    }
}
#endif
