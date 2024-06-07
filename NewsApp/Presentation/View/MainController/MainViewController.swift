//
//  MainViewController.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    private var viewModel: MainViewModel!
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()
    private let searchButton = UIBarButtonItem(systemItem: .search)

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
            viewModel.fetchHeadlines()
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
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = searchButton
        searchButton.target = self
        searchButton.action = #selector(navigateToSearch)
    }

    @objc private func navigateToSearch() {
        let searchVM = SearchViewModel(searchArticlesUseCase: SearchArticlesUseCase(repository: NewsRepositoryImpl(apiService: APIService())))
        let searchVC = SearchViewController()
        searchVC.viewModel = searchVM
        navigationController?.pushViewController(searchVC, animated: true)
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
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url)
        }
    }
}
