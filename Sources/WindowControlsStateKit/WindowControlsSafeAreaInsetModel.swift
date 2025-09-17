//
//  WindowControlsSafeAreaInsetModel.swift
//  WindowControlsSafeAreaInset
//
//  Created by lynnswap on 2025/09/08.
//

#if os(iOS)
import SwiftUI
import Combine

@MainActor
@Observable
public final class WindowControlsSafeAreaInsetModel {

    public var minX: CGFloat = .zero
    var installed: Bool = false

    private weak var containerView: UIView?
    private weak var window: UIWindow?
    private weak var button: UIButton?

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    public init() {}

    public func attach(to containerView: UIView, window: UIWindow) {
        if let currentWindow = self.window,
           currentWindow === window,
           let currentContainer = self.containerView,
           currentContainer === containerView {
            return
        }

        detach()

        self.window = window
        self.containerView = containerView
        installTransparentButton(into: containerView)
        startObservingMinX()
        installed = true
    }

    public func detach() {
        cancellables.removeAll()
        button?.removeFromSuperview()
        button = nil
        containerView = nil
        window = nil
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
        if #available(iOS 26.0, *) {
            guide = containerView.layoutGuide(for: .margins(cornerAdaptation: .horizontal))
        } else {
            guide = containerView.layoutMarginsGuide
        }

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
#endif
