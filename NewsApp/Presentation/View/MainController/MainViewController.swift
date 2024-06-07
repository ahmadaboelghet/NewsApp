//
//  MainViewController.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    private var viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()
    private let searchButton = UIBarButtonItem(systemItem: .search)
    private let favoritesButton = UIBarButtonItem(systemItem: .bookmarks)

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupNavigation()

        if !UserDefaults.standard.bool(forKey: "hasOnboarded") {
            let onboardingVC = OnboardingViewController()
            navigationController?.pushViewController(onboardingVC, animated: true)
        } else {
            let country = UserDefaults.standard.string(forKey: "selectedCountry") ?? "us"
            let categories = UserDefaults.standard.stringArray(forKey: "selectedCategories") ?? ["general"]
            viewModel.fetchHeadlines(country: country, categories: categories)
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Configure and add table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HeadlineCell.self, forCellReuseIdentifier: "HeadlineCell")

        // Set constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$headlines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$favoriteArticles
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // Handle favorite articles update if needed
            }
            .store(in: &cancellables)
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItems = [searchButton, favoritesButton]
        searchButton.target = self
        searchButton.action = #selector(navigateToSearch)
        favoritesButton.target = self
        favoritesButton.action = #selector(showFavorites)
    }

    @objc private func navigateToSearch() {
        let searchVM = SearchViewModel(searchArticlesUseCase: SearchArticlesUseCase(repository: NewsRepositoryImpl(apiService: APIService())))
        let searchVC = SearchViewController()
        searchVC.viewModel = searchVM
        navigationController?.pushViewController(searchVC, animated: true)
    }

    @objc private func showFavorites() {
        viewModel.fetchFavoriteArticles()
        let FavoritesVC = FavoritesViewController(viewModel: viewModel)
        navigationController?.pushViewController(FavoritesVC, animated: true)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.headlines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeadlineCell", for: indexPath) as! HeadlineCell
        let article = viewModel.headlines[indexPath.row]
        cell.configure(with: article)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = viewModel.headlines[indexPath.row]
        if let url = URL(string: article.url ?? "") {
            UIApplication.shared.open(url)
        }
    }

    // Updated to use UIContextualAction instead of UITableViewRowAction
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let article = self.viewModel.headlines[indexPath.row]
            self.viewModel.saveFavorite(article: article)
            completionHandler(true)
        }
        favoriteAction.backgroundColor = .orange

        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
}
