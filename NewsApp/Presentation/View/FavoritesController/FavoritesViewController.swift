//
//  FavoritesViewController.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 08/06/2024.
//

import UIKit
import Combine

class FavoritesViewController: UIViewController {
    private var mainviewModel: MainViewModel?
    private var searchViewModel: SearchViewModel?
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()

    init(mainviewModel: MainViewModel) {
        self.mainviewModel = mainviewModel
        super.init(nibName: nil, bundle: nil)
    }

    init(searchViewModel: SearchViewModel) {
        self.searchViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        mainviewModel?.fetchFavoriteArticles()
        searchViewModel?.fetchFavoriteArticles()
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
        if let searchViewModel = searchViewModel {
            searchViewModel.$favoriteArticles
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        } else if let mainViewModel = mainviewModel {
            mainViewModel.$favoriteArticles
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchViewModel = searchViewModel {
            return searchViewModel.favoriteArticles.count
        } else if let mainViewModel = mainviewModel {
            return mainViewModel.favoriteArticles.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeadlineCell", for: indexPath) as! HeadlineCell
        if let searchViewModel = searchViewModel {
            let article = searchViewModel.favoriteArticles[indexPath.row]
            cell.configure(with: article)
        } else if let mainViewModel = mainviewModel {
            let article = mainViewModel.favoriteArticles[indexPath.row]
            cell.configure(with: article)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchViewModel = searchViewModel {
            let article = searchViewModel.favoriteArticles[indexPath.row]
            if let url = URL(string: article.url ?? "") {
                UIApplication.shared.open(url)
            }
        } else if let mainViewModel = mainviewModel {
            let article = mainViewModel.favoriteArticles[indexPath.row]
            if let url = URL(string: article.url ?? "") {
                UIApplication.shared.open(url)
            }
        }
    }
}
