import UIKit

final class SearchOptionPickerViewController: UIViewController {
    
    private let searchOptionPicker: SearchInputViewModel.SearchInputConstants
    private let searchOptionPickerSelectionBlock: ((String) -> Void)
    private static let searchOptionPickerReuseCellIdentifier = "searchOptionCell"

    private lazy var searchOptionPickerTableView: UITableView = {
        let searchOptionPickerTable = UITableView()
        
        searchOptionPickerTable.translatesAutoresizingMaskIntoConstraints = false
        searchOptionPickerTable.register(UITableViewCell.self, forCellReuseIdentifier: Self.searchOptionPickerReuseCellIdentifier)
        
        return searchOptionPickerTable
    }()

    
    init(option: SearchInputViewModel.SearchInputConstants, selection: @escaping (String) -> Void) {
        self.searchOptionPicker = option
        self.searchOptionPickerSelectionBlock = selection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchOptionPickerTableViewSetup()
    }

    private func searchOptionPickerTableViewSetup() {
        view.addSubview(searchOptionPickerTableView)
        searchOptionPickerTableView.delegate = self
        searchOptionPickerTableView.dataSource = self

        NSLayoutConstraint.activate([
            searchOptionPickerTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchOptionPickerTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchOptionPickerTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            searchOptionPickerTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension SearchOptionPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchOptionPicker.searchInputChoices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchOptionPickerChoice = searchOptionPicker.searchInputChoices[indexPath.row]
        let searchOptionPickerCell = tableView.dequeueReusableCell(withIdentifier: Self.searchOptionPickerReuseCellIdentifier, for: indexPath)
        
        searchOptionPickerCell.textLabel?.text = searchOptionPickerChoice.uppercased()
        
        return searchOptionPickerCell
    }

    func tableView(_ searchOptionPickerTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchOptionPickerTableView.deselectRow(at: indexPath, animated: true)
        let searchOptionPickerChoice = searchOptionPicker.searchInputChoices[indexPath.row]
        self.searchOptionPickerSelectionBlock(searchOptionPickerChoice)
        dismiss(animated: true)
    }
}
