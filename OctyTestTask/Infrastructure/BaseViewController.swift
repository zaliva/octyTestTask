import UIKit

class BaseViewController<T>: UIViewController where T: ViewModel {
    var viewModel: T!
    
    var initialInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?

    private var tapGesture: UITapGestureRecognizer?
    private var bottomViewConstant: CGFloat?
    
    /// height for handle idstanse between BottomView and keyboard
    /// default is '- bottomView height'
    /// if bottomView is equal to nil heightToKeyboard = 0
    var heightToKeyboard: CGFloat {
        return -(bottomView?.frame.size.height ?? 0)
    }
    
    /// insets between keyboard and view
    var bottomInsetToKeyboard: CGFloat {
        return 0
    }
    
    /// BottomView - placed in the bottom of view for show above keyboard
    var bottomView: UIView? {
        return nil
    }
    
    /// default return false, if need to enable keyboard observers/methods override to 'true'
    var isKeyboardNotificationsEnable: Bool {
        return false
    }
    
    /// default return false, if need to enable dissmis keyboard on tap override to 'true'
    var hideKeyboardOnTap: Bool {
        return false
    }
    
    /// override for enable inset changes when keyboard shown and hidden
    var childScrollView: UIScrollView? {
        return nil
    }
    
    /// override if need to change 0 inset
    var childScrollViewTopInset: CGFloat {
        return 0
    }
    
    /// override if need to change 0 inset
    var childScrollViewBottomInset: CGFloat {
        return 0
    }
    
    var cancelsTouchesInView: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        updateScrollViewContentInset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        navigationController?.isNavigationBarHidden = true

        registerNotificationObservers(isKeyboardNotificationsEnable)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        initialInteractivePopGestureRecognizerDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotificationObservers()
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = initialInteractivePopGestureRecognizerDelegate
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
    }
    
    // MARK: - NotificationObserver
    
    private func registerNotificationObservers(_ register: Bool = false) {
        if hideKeyboardOnTap {
            hideKeyboardWhenTappedAround()
        }

        if register {
            ENManager.add(UIApplication.willEnterForegroundNotification, identifier: self) { [weak self] _ in
                guard let self = self else { return }
                self.willEnterForeground()
            }

            ENManager.add(UIApplication.didEnterBackgroundNotification, identifier: self) { [weak self] _ in
                guard let self = self else { return }
                self.didEnterBackground()
            }
            
            ENManager.add(UIResponder.keyboardWillShowNotification, identifier: self) { [weak self] notif in
                self?.keyboardWillShow(notif)
            }
            ENManager.add(UIResponder.keyboardWillHideNotification, identifier: self) { [weak self] notif in
                self?.keyboardWillHide(notif)
            }
        }
    }
    
    @objc func willEnterForeground() {
        viewModel.willEnterForeground()
    }

    @objc func didEnterBackground() {
        viewModel.didEnterBackground()
    }
    
    private func removeNotificationObservers() {
        removeDismissTap()
        ENManager.removeAllIn(self)
    }
    
    private func getKeyboardSize(from: Notification) -> CGSize {
        if let keyboardFrame: NSValue = from.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardSize = keyboardFrame.cgRectValue.size
            return keyboardSize
        }
        return .zero
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        keyboardWill(show: getKeyboardSize(from: notification))
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardWill(hide: getKeyboardSize(from: notification))
    }
    
    /// Method calls when keyboard will show
    ///
    /// - Parameter show: keyboard size
    func keyboardWill(show: CGSize) {
        if bottomView != nil {
            let bottomConstraint = bottomView?.bottomConstraintToSuperView()
            
            if bottomViewConstant == nil {
                bottomViewConstant = bottomConstraint?.constant
            }
            
            var constant = show.height + bottomInsetToKeyboard

            if let isTabBarHidden = tabBarController?.tabBar.isHidden, !isTabBarHidden {
                constant -= tabBarController?.tabBar.bounds.height ?? 0
            } else {
                let safeAreaBottomInset: CGFloat = {
                    if #available(iOS 13.0, *) {
                        return UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .flatMap { $0.windows }
                            .first { $0.isKeyWindow }?
                            .safeAreaInsets.bottom ?? 0
                    } else {
                        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                    }
                }()
                constant -= safeAreaBottomInset
            }

            bottomConstraint?.constant = constant
            animate()
        }
        updateScrollViewContentInset(additionBottom: show.height)
    }
    
    /// Method calls when keyboard will hide
    ///
    /// - Parameter show: keyboard size
    func keyboardWill(hide: CGSize) {
        if bottomView != nil {
            let defaultConstant: CGFloat = 16
            bottomView?.bottomConstraintToSuperView()?.constant = bottomViewConstant ?? defaultConstant
            bottomViewConstant = nil
            animate()
        }
        updateScrollViewContentInset()
    }
    
    private func updateScrollViewContentInset(additionBottom: CGFloat = 0) {
        let top = childScrollViewTopInset
        let bottom = childScrollViewBottomInset + additionBottom
        childScrollView?.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    func animate() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func hideKeyboardWhenTappedAround() {
        let dismissTap = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(dismissTap)
        tapGesture = dismissTap
    }
    
    private func removeDismissTap() {
        guard let tap = tapGesture else {
            return
        }
        view.removeGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    
    func bottomConstraintToSuperView() -> NSLayoutConstraint? {
        guard let supView = superview else {
            return nil
        }
        for const in supView.constraints where const.secondAnchor == bottomAnchor || const.firstAnchor == bottomAnchor {
            return const
        }
        return nil
    }
}
