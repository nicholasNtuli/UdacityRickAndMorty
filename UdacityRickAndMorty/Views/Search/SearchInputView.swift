import UIKit

protocol SearchInputViewDelegate: AnyObject {
    func searchInputSelectionView(_ inputView: SearchInputView, selectOption option: SearchInputViewModel.SearchInputConstants)
    func searchInputField(_ inputView: SearchInputView, changeSearchText text: String)
    func searchInputTapped(_ inputView: SearchInputView)
}

final class SearchInputView: UIView {
    weak var searchInputDelegate: SearchInputViewDelegate?
    private var searchInputStackView: UIStackView?
    
    private let searchInputSearchBar: UISearchBar = {
        let searchInputSearchBar = UISearchBar()
        searchInputSearchBar.placeholder = "Search"
        searchInputSearchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchInputSearchBar
    }()
    
    private var searchInputViewModel: SearchInputViewModel? {
        didSet {
            guard let searchInputViewModel = searchInputViewModel, searchInputViewModel.searchInputConstant else {
                return
            }
            let searchInputOptions = searchInputViewModel.searchInputOptions
            createSearchInputOptionSelectionViews(searchInputOptions: searchInputOptions)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchInputConfigureView()
        searchInputSubviewsSetup()
        searchInputConstraintsSetup()
        configureSearchInputSearchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func searchInputConfigureView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func searchInputSubviewsSetup() {
        addCharacterDetailLoadingIndicatorSubviews(searchInputSearchBar)
    }
    
    private func searchInputConstraintsSetup() {
        NSLayoutConstraint.activate([
            searchInputSearchBar.topAnchor.constraint(equalTo: topAnchor),
            searchInputSearchBar.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputSearchBar.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputSearchBar.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
    
    private func configureSearchInputSearchBar() {
        searchInputSearchBar.delegate = self
    }
    
    private func createSearchInputOptionStackView() -> UIStackView {
        let searchInputOptionStackView = UIStackView()
        searchInputOptionStackView.translatesAutoresizingMaskIntoConstraints = false
        searchInputOptionStackView.axis = .horizontal
        searchInputOptionStackView.spacing = 6
        searchInputOptionStackView.distribution = .fillEqually
        searchInputOptionStackView.alignment = .center
        addSubview(searchInputOptionStackView)
        
        NSLayoutConstraint.activate([
            searchInputOptionStackView.topAnchor.constraint(equalTo: searchInputSearchBar.bottomAnchor),
            searchInputOptionStackView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputOptionStackView.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputOptionStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        return searchInputOptionStackView
    }
    
    private func createSearchInputOptionSelectionViews(searchInputOptions: [SearchInputViewModel.SearchInputConstants]) {
        let searchInputOptionStackView = createSearchInputOptionStackView()
        
        self.searchInputStackView = searchInputOptionStackView
        
        for (searchInputIndex, searchInputOption) in searchInputOptions.enumerated() {
            let searchInputButton = createSearchInputButton(with: searchInputOption, searchInputTag: searchInputIndex)
            searchInputOptionStackView.addArrangedSubview(searchInputButton)
        }
    }
    
    private func createSearchInputButton(with searchInputOption: SearchInputViewModel.SearchInputConstants, searchInputTag: Int) -> UIButton {
        let searchInputButton = UIButton()
        
        searchInputButton.setAttributedTitle(
            NSAttributedString(
                string: searchInputOption.rawValue,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.label
                ]
            ),
            for: .normal
        )
        
        searchInputButton.backgroundColor = .secondarySystemFill
        searchInputButton.addTarget(self, action: #selector(tapSearchInputButton(_:)), for: .touchUpInside)
        searchInputButton.tag = searchInputTag
        searchInputButton.layer.cornerRadius = 6
        
        return searchInputButton
    }
    
    @objc
    private func tapSearchInputButton(_ searchInputSender: UIButton) {
        guard let searchInputOptions = searchInputViewModel?.searchInputOptions else {
            return
        }
        
        let searchInputag = searchInputSender.tag
        let searchInputSelected = searchInputOptions[searchInputag]
        
        searchInputDelegate?.searchInputSelectionView(self, selectOption: searchInputSelected)
    }
    
    public func searchInputconfiguration(with searchInputconfigurationViewModel: SearchInputViewModel) {
        searchInputSearchBar.placeholder = searchInputconfigurationViewModel.searchInputPlaceholderTexts
        self.searchInputViewModel = searchInputconfigurationViewModel
    }
    
    public func presentSearchInputKeyboard() {
        searchInputSearchBar.becomeFirstResponder()
    }
    
    public func updatesearchInput(searchInputOption: SearchInputViewModel.SearchInputConstants, searchInputValue: String) {
        guard let searchInputButtons = searchInputStackView?.arrangedSubviews as? [UIButton],
              let searchInputListOptions = searchInputViewModel?.searchInputOptions,
              let searchInputIndex = searchInputListOptions.firstIndex(of: searchInputOption) else {
            return
        }
        
        searchInputButtons[searchInputIndex].setAttributedTitle(
            NSAttributedString(
                string: searchInputValue.uppercased(),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.link
                ]
            ),
            for: .normal
        )
    }
}

extension SearchInputView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchInputDelegate?.searchInputField(self, changeSearchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchInputSearchBar: UISearchBar) {
        searchInputSearchBar.resignFirstResponder()
        searchInputDelegate?.searchInputTapped(self)
    }
}
