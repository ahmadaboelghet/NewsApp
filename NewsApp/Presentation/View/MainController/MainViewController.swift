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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()

        if !UserDefaults.standard.bool(forKey: "hasOnboarded") {
            let onboardingVC = OnboardingViewController()
            navigationController?.pushViewController(onboardingVC, animated: true)
        } else {
            viewModel.fetchHeadlines()
        }
    }

    private func setupUI() {
        // Configure table view
    }

    private func bindViewModel() {
        viewModel.$headlines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}
