import UIKit
import SnapKit

class ConsoleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var filterType = LoggerType.allTypeWithoutDebug
    private var _logsArray = [LogModel]()
    private var logsArray: [LogModel] {
        get {
            if filterType == .allType {
                return _logsArray
            }
            if filterType == .allTypeWithoutDebug {
                return _logsArray.filter { $0.logType != .debugLog }
            }
            return _logsArray.filter { $0.logType == filterType }
        }
        set { _logsArray = newValue }
    }

    class func instance() -> ConsoleViewController? {
        return UIStoryboard(name: "ConsoleViewController", bundle: nil).instantiateViewController(withIdentifier: "ConsoleViewController") as? ConsoleViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logsArray = LoggerManager.getLogs()
        tableView.reloadData()
    }

    @IBAction func selectFilter(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        ArrayLoggerType.forEach { logType in
            actionSheet.addAction(UIAlertAction(title: logType.rawValue, style: .default, handler: { [weak self] _ in
                self?.filterType = logType
                self?.tableView.reloadData()
            }))
        }

        let cancelAction = UIAlertAction(title: LocalizeStrings.cancel, style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func clearLog(_ sender: Any) {
        LoggerManager.removeLogsFile()
        logsArray = [LogModel]()
        tableView.reloadData()
    }
}

extension ConsoleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConsoleCell.cellID, for: indexPath)
        guard let cell = cell as? ConsoleCell else { return cell }
        let model = logsArray[indexPath.row]
        cell.textView.attributedText = model.attributedText
        cell.textView.isUserInteractionEnabled = model.isShowFull
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = logsArray[indexPath.row]
        if model.isShowFull {
            return model.attributedText.string.height(width: UIScreen.main.bounds.size.width - 40, font: UIFont.systemFont(ofSize: 14, weight: .regular))
        } else {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logsArray[indexPath.row].isShowFull.toggle()
        self.tableView.reloadRows(at: [indexPath], with: .middle)
    }
}

class ConsoleCell: UITableViewCell {
    static let cellID = String(describing: ConsoleCell.self)

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.isEditable = false
        }
    }
}
