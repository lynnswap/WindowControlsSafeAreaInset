//
//  WindowControlsStateModel+Environment.swift
//  WindowControlsSafeAreaInset
//

#if os(iOS)
import SwiftUI

public extension EnvironmentValues {
    @Entry var windowControlsStateModel: WindowControlsStateModel? = nil
}

private struct WindowControlsStateModelProvider: ViewModifier {
    @State private var model: WindowControlsStateModel?

    func body(content: Content) -> some View {
        if let model {
            content
                .environment(\.windowControlsStateModel, model)
        } else {
            Color.clear
                .onAppear {
                    self.model = WindowControlsStateModel()
                }
        }
    }
}

public extension View {
    func windowControlsStateModel() -> some View {
        modifier(WindowControlsStateModelProvider())
    }

    func windowControlsStateModel(_ model: WindowControlsStateModel?) -> some View {
        environment(\.windowControlsStateModel, model)
    }
}
#endif
