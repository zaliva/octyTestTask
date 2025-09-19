
import UIKit

let Toast = ToastEntity.shared

class ToastEntity {
    static let shared = ToastEntity()
    private var view: UIView?
    private var imageView: UIImageView?
    
    private init() {}
    
    func show(isShowBackground: Bool = true) {
        dismiss()
        
        imageView = UIImageView()
        view = UIView()
        guard let imageView = imageView, let view = view else { return }
        
        UIApplication.shared.currentKeyWindow?.addSubview(view)
        if isShowBackground {
            view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        }
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(imageView)
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "spinerIcon")
        imageView.tintColor = .link
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        rotate(imageView: imageView)
    }
    
    func showDebugMessage(_ msg: String) {
        print(msg)
    }
    
    func rotate(imageView: UIImageView) {
         let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
         rotationAnimation.values = [0, Double.pi, Double.pi * 2]
         rotationAnimation.duration = 0.6
         rotationAnimation.repeatCount = .infinity
         imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func dismiss() {
        view?.removeFromSuperview()
        imageView?.removeFromSuperview()
    }
}
