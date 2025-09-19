import UIKit

class LoggerAppIconView: UIView {

    private var logoTapCount = 0
    private var openConsoleWorkItem: DispatchWorkItem?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        backgroundColor = UIColor.init(red: 0.2, green: 1, blue: 1, alpha: 1)
        let tapGeature = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        addGestureRecognizer(tapGeature)
        setupAppIcon()
    }

    private func setupAppIcon() {
        let sizeIcon: CGFloat = 150
        let appIcon = UIImageView()
        appIcon.frame = CGRect(x: (ScreenWidth - sizeIcon)/2, y: (ScreenHeight - sizeIcon)/2, width: sizeIcon, height: sizeIcon)
        addSubview(appIcon)
        appIcon.image = UIImage(systemName: "heart.fill")
        appIcon.layer.cornerRadius = 5
        appIcon.clipsToBounds = true
        appIcon.isUserInteractionEnabled = true
        let tapGeature = UITapGestureRecognizer(target: self, action: #selector(onLogoTap))
        tapGeature.numberOfTouchesRequired = 2
        appIcon.addGestureRecognizer(tapGeature)
    }

    @objc private func onLogoTap() {
        guard LoggerManager.enableLogger else { return }
        logoTapCount += 1
        // Show console if 9 times tap on logo
        if logoTapCount == 9 { showConsoleVC() }

        openConsoleWorkItem?.cancel()
        openConsoleWorkItem = DispatchWorkItem(block: {
            self.logoTapCount = 0
        })

        if let item = openConsoleWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)
        }
    }

    private func showConsoleVC() {
        dismissView()
        guard LoggerManager.enableLogger, let vc = ConsoleViewController.instance() else { return }
        vc.modalPresentationStyle = .fullScreen
        Coordinator.currentNavigationController?.present(vc, animated: true)
    }

    @objc private func dismissView() {
        removeFromSuperview()
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard LoggerManager.enableLogger else { return }
        if motion == .motionShake {
            let appIconImageView = LoggerAppIconView()
            UIApplication.shared.currentKeyWindow?.addSubview(appIconImageView)
        }
    }
}
