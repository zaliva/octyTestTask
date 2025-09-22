import UIKit

protocol RatesViewControllerProtocol: NSObjectProtocol {
    func updateCollectionView()
    func showError(error: ApiError)
}

class RatesViewController: BaseViewController<RatesViewModel> {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private var adapter: RatesCollectionAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        titleLabel.text = viewModel.type.rawValue
    }
    
    private func configureCollectionView() {
        collectionView.register(RatesCell.nib, forCellWithReuseIdentifier: RatesCell.reuseID)
        collectionView.setCollectionViewLayout(Self.makeLayout(), animated: false)
        
        adapter = RatesCollectionAdapter(collectionView: collectionView)
        adapter.onStarTap = { [weak self] index in
            guard let self else { return }
            guard self.viewModel.ratesModels.indices.contains(index) else { return }
            self.viewModel.addOrRemoveFavorites(model: self.viewModel.ratesModels[index])
        }
    }
    
    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(CGFloat(RatesCell.heghtCell))
            )
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(CGFloat(RatesCell.heghtCell))
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 0
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension RatesViewController: RatesViewControllerProtocol {
    func updateCollectionView() {
        adapter.apply(viewModel.ratesModels, animating: true)
    }
    
    func showError(error: ApiError) {
        let alert = UIAlertController(title: error.propertyName, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - Diffable Adapter
final class RatesCollectionAdapter: NSObject {
    typealias Section = Int
    enum Item: Hashable { case rate(RatesDataModel) }

    private let collectionView: UICollectionView
    private lazy var dataSource = makeDataSource()

    /// Called when the star button is tapped; provides item index.
    var onStarTap: ((Int) -> Void)?

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
    }

    func apply(_ models: [RatesDataModel], animating: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(models.map { .rate($0) }, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] cv, indexPath, item in
            switch item {
            case .rate(let model):
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: RatesCell.reuseID, for: indexPath) as? RatesCell else {
                    return UICollectionViewCell()
                }
                cell.configureView(model: model)
                cell.addOrRemoveFavorites = { [weak self, weak cv, weak cell] in
                    guard
                        let self,
                        let cv,
                        let cell,
                        let indexPath = cv.indexPath(for: cell)
                    else { return }
                    self.onStarTap?(indexPath.item)
                }
                return cell
            }
        }
    }
}

extension RatesCollectionAdapter: UICollectionViewDelegate {}
