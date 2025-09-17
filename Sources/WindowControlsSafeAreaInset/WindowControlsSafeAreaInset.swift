// The Swift Programming Language
// https://docs.swift.org/swift-book
#if os(iOS)
import SwiftUI

private struct WindowControlsSafeAreaInsetModifier<Overlay: View>: ViewModifier {
    @Environment(\.windowControlsSafeAreaInsetModel) private var environmentModel
    @State private var fallbackModel: WindowControlsSafeAreaInsetModel?

    let alignment: Alignment
    let extraLeading: CGFloat
    let overlay: () -> Overlay

    func body(content: Content) -> some View {
#if swift(>=6.2)
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
                        ContainerReader { view, window in
                            if let window {
                                model.attach(to: view, window: window)
                            } else {
                                model.detach()
                            }
                        }
                    )
            }else{
                content
                    .background(
                        Color.clear
                            .onAppear {
                                if fallbackModel == nil {
                                    fallbackModel = WindowControlsSafeAreaInsetModel()
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
#else
        content
            .overlay(alignment: alignment) {
                overlay()
                    .padding(.leading, extraLeading)
            }
#endif
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
