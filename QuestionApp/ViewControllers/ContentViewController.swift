//
//  ContentViewController.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//
import UIKit
import Alamofire

class ContentViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ContentViewModel
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.separatorStyle = .none
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()
    
    private let errorView = ErrorView()
    private var expandedItems = Set<UUID>()
    private var currentItems: [(item: Item, level: Int)] = []
    private let refreshControl = UIRefreshControl()
    private let lastUpdateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "Not updated yet"
        return label
    }()
    
    private let networkStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .orange
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var updateTimer: Timer?
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Initialization
    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchContent()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup Navigation Bar
        title = "Content"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .white
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableView.refreshControl = refreshControl
        
        tableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
        
        // Configure for dynamic sizing
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorView)
        view.addSubview(lastUpdateLabel)
        view.addSubview(networkStatusLabel)
        
        // Setup constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        lastUpdateLabel.translatesAutoresizingMaskIntoConstraints = false
        networkStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            networkStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            networkStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            networkStatusLabel.bottomAnchor.constraint(equalTo: lastUpdateLabel.topAnchor, constant: -4),
            
            lastUpdateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lastUpdateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lastUpdateLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        errorView.isHidden = true
        tableView.isHidden = true
        updateLastUpdateLabel()
        
        startUpdateTimer()
    }
    
    private func setupBindings() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(for: state)
            }
        }
        
        errorView.retryAction = { [weak self] in
            self?.viewModel.fetchContent()
        }
    }
    
    @objc private func refreshContent() {
        viewModel.fetchContent(forceRefresh: true)
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateLastUpdateLabel()
        }
    }
    
    private func updateLastUpdateLabel() {
        let lastUpdateText = viewModel.getLastUpdateTime()
        lastUpdateLabel.text = lastUpdateText
    }
    
    private func updateNetworkStatus(isOffline: Bool) {
        networkStatusLabel.isHidden = !isOffline
        if isOffline {
            networkStatusLabel.text = "You're offline. Showing saved data."
        }
    }
    
    private func updateUI(for state: ContentViewModel.State) {
        switch state {
        case .loading:
            if !refreshControl.isRefreshing {
                activityIndicator.startAnimating()
            }
            errorView.isHidden = true
            tableView.isHidden = true
        case .loaded:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            errorView.isHidden = true
            tableView.isHidden = false
            currentItems = flattenedItems()
            tableView.reloadData()
            updateLastUpdateLabel()
            updateNetworkStatus(isOffline: false)
        case .error(let error):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            if currentItems.isEmpty {
                errorView.isHidden = false
                tableView.isHidden = true
                errorView.configure(with: error)
            } else {
                updateNetworkStatus(isOffline: true)
                showToast(message: error.localizedDescription)
            }
        }
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastLabel.bottomAnchor.constraint(equalTo: networkStatusLabel.topAnchor, constant: -8)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleExpansion(for item: Item) {
        if expandedItems.contains(item.id) {
            expandedItems.remove(item.id)
        } else {
            expandedItems.insert(item.id)
        }
        currentItems = flattenedItems()
    }
    
    private func isExpanded(_ item: Item) -> Bool {
        return expandedItems.contains(item.id)
    }
    
    private func flattenedItems() -> [(item: Item, level: Int)] {
        var flattened: [(item: Item, level: Int)] = []
        
        func flatten(_ items: [Item], level: Int) {
            for item in items {
                flattened.append((item: item, level: level))
                if isExpanded(item), let subitems = item.items {
                    flatten(subitems, level: level + 1)
                }
            }
        }
        
        flatten(viewModel.items, level: 0)
        return flattened
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemWithLevel = currentItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        cell.delegate = self
        cell.configure(with: itemWithLevel.item, nestingLevel: itemWithLevel.level, isExpanded: isExpanded(itemWithLevel.item))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let itemWithLevel = currentItems[indexPath.row]
        
        if itemWithLevel.item.items?.isEmpty == false {
            toggleExpansion(for: itemWithLevel.item)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let itemWithLevel = currentItems[indexPath.row]
        let item = itemWithLevel.item
        
        switch item.itemType {
        case .image:
            return DesignSystem.Layout.imageHeight
        case .text, .section, .page:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - QuestionCellDelegate
extension ContentViewController: QuestionCellDelegate {
    func questionCell(_ cell: QuestionCell, didTapExpandFor item: Item) {
        let oldItems = currentItems
        
        guard let itemIndex = oldItems.firstIndex(where: { $0.item.id == item.id }) else { return }
        
        toggleExpansion(for: item)
        
        var indexPathsToDelete: [IndexPath] = []
        var indexPathsToInsert: [IndexPath] = []
        
        if isExpanded(item) {
            if let items = item.items {
                let insertStartIndex = itemIndex + 1
                indexPathsToInsert = (0..<items.count).map {
                    IndexPath(row: insertStartIndex + $0, section: 0)
                }
            }
        } else {
            var deleteCount = 0
            var currentIndex = itemIndex + 1
            
            while currentIndex < oldItems.count {
                if oldItems[currentIndex].level <= oldItems[itemIndex].level {
                    break
                }
                deleteCount += 1
                currentIndex += 1
            }
            
            indexPathsToDelete = (0..<deleteCount).map {
                IndexPath(row: itemIndex + 1 + $0, section: 0)
            }
        }
        
        // Perform batch updates
        tableView.performBatchUpdates({
            if !indexPathsToDelete.isEmpty {
                tableView.deleteRows(at: indexPathsToDelete, with: .none)
            }
            if !indexPathsToInsert.isEmpty {
                tableView.insertRows(at: indexPathsToInsert, with: .none)
            }
        }) { [weak self] _ in
            guard let self = self else { return }
            if let indexPath = self.tableView.indexPath(for: cell) {
                cell.configure(with: item,
                               nestingLevel: self.currentItems[indexPath.row].level,
                               isExpanded: self.isExpanded(item))
            }
        }
    }
    
    func questionCell(_ cell: QuestionCell, didTapImageAt imageFrame: CGRect) {
        if let imageCell = cell as? QuestionCell,
           let image = imageCell.contentImageView.image {
            let imageVC = ImageViewController(image: image, sourceImageView: imageCell.contentImageView, originalFrame: imageFrame)
            present(imageVC, animated: false)
        }
    }
}
