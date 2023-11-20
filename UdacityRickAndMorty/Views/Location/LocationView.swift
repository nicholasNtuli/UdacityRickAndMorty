import UIKit

protocol LocationViewDelegate: AnyObject {
    func locationView(_ locationView: LocationView, select location: Location)
}

final class LocationView: UIView {

    public weak var delegate: LocationViewDelegate?

    private var viewModel: LocationViewModel? {
        didSet {
            updateUI()
            configurePaginationHandling()
        }
    }

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.alpha = 0
        table.isHidden = true
        table.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.cellIdentifier)
        return table
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        return loadingIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tableView, loadingIndicator)
        loadingIndicator.startAnimating()
        addConstraints()
        configureTable()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    private func updateUI() {
        loadingIndicator.stopAnimating()
        tableView.isHidden = false
        tableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 1
        }
    }

    private func configurePaginationHandling() {
        viewModel?.registerFinishPaginationBlock { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.tableFooterView = nil
                self?.tableView.reloadData()
            }
        }
    }

    private func configureTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            loadingIndicator.heightAnchor.constraint(equalToConstant: 100),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 100),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    public func configure(with viewModel: LocationViewModel) {
        self.viewModel = viewModel
    }
}

extension LocationView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let locationModel = viewModel?.location(at: indexPath.row) else {
            return
        }
        delegate?.locationView(self, select: locationModel)
    }
}

extension LocationView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cellViewModels.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModels = viewModel?.cellViewModels else {
            assertionFailure("Cell view models not available")
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.cellIdentifier, for: indexPath) as? LocationTableViewCell else {
            assertionFailure("Failed to dequeue LocationTableViewCell")
            return UITableViewCell()
        }

        let cellViewModel = cellViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension LocationView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !viewModel.cellViewModels.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreLocations else {
            return
        }

        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height

        if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
            showLoadingIndicator()
            viewModel.fetchAdditionalLocations()
        }
    }

    private func showLoadingIndicator() {
        let footer = TableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        tableView.tableFooterView = footer
    }
}
