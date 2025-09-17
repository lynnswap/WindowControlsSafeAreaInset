//
//  WindowControlsSafeAreaInsetModel+Environment.swift
//  WindowControlsSafeAreaInset
//

#if os(iOS)
import SwiftUI

private struct WindowControlsSafeAreaInsetModelKey: EnvironmentKey {
    static let defaultValue: WindowControlsSafeAreaInsetModel? = nil
}

public extension EnvironmentValues {
    var windowControlsSafeAreaInsetModel: WindowControlsSafeAreaInsetModel? {
        get { self[WindowControlsSafeAreaInsetModelKey.self] }
        set { self[WindowControlsSafeAreaInsetModelKey.self] = newValue }
    }
}

private struct WindowControlsSafeAreaInsetModelProvider: ViewModifier {
    @State private var model: WindowControlsSafeAreaInsetModel?

    func body(content: Content) -> some View {
        if let model {
            content
                .environment(\.windowControlsSafeAreaInsetModel, model)
        } else {
            Color.clear
                .onAppear {
                    self.model = WindowControlsSafeAreaInsetModel()
                }
        }
    }
}

public extension View {
    func windowControlsSafeAreaInsetModel() -> some View {
        modifier(WindowControlsSafeAreaInsetModelProvider())
    }

    func windowControlsSafeAreaInsetModel(_ model: WindowControlsSafeAreaInsetModel?) -> some View {
        environment(\.windowControlsSafeAreaInsetModel, model)
    }
}
#endif
