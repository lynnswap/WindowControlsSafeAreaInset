//
//  WindowControlsSafeAreaInsetModel+ProbeView.swift
//  WindowControlsSafeAreaInset
//

#if os(iOS)
import SwiftUI

struct ContainerReader: UIViewRepresentable {
    typealias UIViewType = ProbeView

    let model: WindowControlsSafeAreaInsetModel

    init(model: WindowControlsSafeAreaInsetModel) {
        self.model = model
    }

    func makeUIView(context: Context) -> ProbeView {
        ProbeView(model: model)
    }

    func updateUIView(_ uiView: ProbeView, context: Context) {}
}

@MainActor
final class ProbeView: UIView {
    init(model: WindowControlsSafeAreaInsetModel) {
        self.model = model
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var model: WindowControlsSafeAreaInsetModel? {
        didSet {
            guard oldValue !== model else {
                resolveAttachment()
                return
            }
            oldValue?.detach()
            resolveAttachment()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        resolveAttachment()
    }

    private func resolveAttachment() {
        guard let model else { return }
        if let window {
            model.attach(to: self, window: window)
        } else {
            model.detach()
        }
    }
}
#endif
