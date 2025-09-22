
import UIKit

class RatesCell: UICollectionViewCell {
    
    private var currentModel: RatesDataModel?
    
    static let heghtCell = CGFloat(80.0)
    static let reuseID = String(describing: RatesCell.self)
    static let nib = UINib(nibName: String(describing: RatesCell.self), bundle: nil)
    
    var addOrRemoveFavorites: (() -> Void)?
    
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var addOrRemoveFavoritesBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureView(model: RatesDataModel) {
        self.currentModel = model
        coinLabel.text = "\(model.baseCurrency ?? "")/\(model.quoteCurrency ?? "")"
        descriptionLabel.text = "1 \(model.baseCurrency ?? "") = \(model.quote) \(model.quoteCurrency ?? "")"
        valueLabel.text = "\(model.quote)"
        let image = model.isFavorites ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        addOrRemoveFavoritesBtn.setImage(image, for: .normal)
    }
    
    @IBAction func addOrRemoveFavoritesAction(_ sender: Any) {
        if let model = currentModel {
            let image = !model.isFavorites ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            addOrRemoveFavoritesBtn.setImage(image, for: .normal)
        }
        addOrRemoveFavorites?()
    }
}
