//
//  WindowControlsSafeAreaInsetModel.swift
//  WindowControlsSafeAreaInset
//
//  Created by lynnswap on 2025/09/08.
//


import SwiftUI
import Combine
@MainActor
@Observable
final class WindowControlsSafeAreaInsetModel {

    var minX: CGFloat = .zero
    var installed: Bool = false

    private weak var containerView: UIView?
    private weak var button: UIButton?

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    func attach(to containerView: UIView) {
        guard !installed || self.containerView !== containerView else { return }
        self.containerView = containerView
        installTransparentButton(into: containerView)
        startObservingMinX()
        installed = true
    }

    func detach() {
        cancellables.removeAll()
        button?.removeFromSuperview()
        button = nil
        installed = false
    }

    // MARK: - Private

    private func installTransparentButton(into containerView: UIView) {
        if let b = button, b.superview === containerView { return }

        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.configuration = nil
        btn.backgroundColor = .clear
        btn.setTitle(nil, for: .normal)
        btn.setImage(nil,  for: .normal)
        btn.isAccessibilityElement = true
        btn.accessibilityLabel = "Window controls area"

        containerView.addSubview(btn)
        
        let guide: UILayoutGuide
#if swift(>=6.2)
        if #available(iOS 26.0, *) {
            guide = containerView.layoutGuide(for: .margins(cornerAdaptation: .horizontal))
        } else {
            guide = containerView.layoutMarginsGuide
        }
#else
        guide = containerView.layoutMarginsGuide
#endif

        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            btn.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8)
        ])

        containerView.layoutIfNeeded()

        self.button = btn
        self.minX = btn.frame.minX
    }

    private func startObservingMinX() {
        cancellables.removeAll()
        guard let button else { return }

        let positionP = button.layer
            .publisher(for: \.position, options: [.initial, .new])
            .compactMap { [weak button] _ in button?.frame.minX }

        let boundsP = button.layer
            .publisher(for: \.bounds, options: [.new])
            .compactMap { [weak button] _ in button?.frame.minX }

        positionP
            .merge(with: boundsP)
//            .removeDuplicates { abs($0 - $1) < 0.5 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMinX in
                self?.minX = newMinX
            }
            .store(in: &cancellables)
    }
}
struct ContainerReader: UIViewRepresentable {
    typealias UIViewType = ProbeView

    var onResolve: @MainActor (_ containerView: UIView, _ window: UIWindow?) -> Void

    func makeUIView(context: Context) -> ProbeView {
        let v = ProbeView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        v.onWindowChanged = { [onResolve] view, window in
            onResolve(view, window)
        }
        return v
    }

    func updateUIView(_ uiView: ProbeView, context: Context) {
    }
}

@MainActor
final class ProbeView: UIView {
    var onWindowChanged: ((_ view: UIView, _ window: UIWindow?) -> Void)?

    private var didAttachOnce = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onWindowChanged?(self, window)
        if window != nil { didAttachOnce = true }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // if didAttachOnce { onWindowChanged?(self, window) }
    }

}
