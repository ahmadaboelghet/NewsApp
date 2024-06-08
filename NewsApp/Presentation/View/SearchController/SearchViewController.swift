//
//  SearchViewController.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import UIKit
import Combine

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    var viewModel: SearchViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let favoritesButton = UIBarButtonItem(systemItem: .bookmarks)
    private let collectionView: UICollectionView
    
    private let allCategories = ["General", "Business", "Technology", "Entertainment", "Sports", "Health", "Science"]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSelectedCategories()
        setupUI()
        bindViewModel()
        setupNavigation()

    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configure search bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "Placeholder for the search bar")
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        // Configure collection view for category selection
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCell")
        view.addSubview(collectionView)
        
        // Configure and add table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Set constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItems = [favoritesButton]
        favoritesButton.target = self
        favoritesButton.action = #selector(showFavorites)
    }
    
    @objc private func showFavorites() {
        viewModel.fetchFavoriteArticles()
        let FavoritesVC = FavoritesViewController(searchViewModel: viewModel)
        navigationController?.pushViewController(FavoritesVC, animated: true)
    }
    
    private func loadSelectedCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: "selectedCategories") as? [String] {
            viewModel.selectedCategories = savedCategories
        } else {
            viewModel.selectedCategories = [] // Default to no selection if nothing is saved
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            viewModel.searchArticles(query: query)
        }
    }
    
    // TableView DataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        let article = viewModel.searchResults[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = viewModel.searchResults[indexPath.row]
        if let url = URL(string: article.url ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let article = self.viewModel.searchResults[indexPath.row]
            self.viewModel.saveFavorite(article: article)
            completionHandler(true)
        }
        favoriteAction.backgroundColor = .orange

        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() } // Clear previous content
        
        let label = UILabel(frame: cell.contentView.bounds)
        label.text = allCategories[indexPath.item]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(label)
        
        let category = allCategories[indexPath.item].lowercased()
        cell.contentView.backgroundColor = viewModel.selectedCategories.contains(category) ? .blue : .lightGray
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = allCategories[indexPath.item].lowercased()
        
        if viewModel.selectedCategories.contains(selectedCategory) {
            viewModel.selectedCategories.removeAll { $0 == selectedCategory }
        } else {
            viewModel.selectedCategories.append(selectedCategory)
        }
        
        // Save updated categories to UserDefaults
        UserDefaults.standard.set(viewModel.selectedCategories, forKey: "SelectedCategories")
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = allCategories[indexPath.item]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: 40)
    }
}

