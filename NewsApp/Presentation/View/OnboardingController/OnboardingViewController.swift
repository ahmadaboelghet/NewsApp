//
//  OnboardingViewController.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 06/06/2024.
//

import UIKit

class OnboardingViewController: UIViewController {

    // UI elements
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!

    var selectedCountry: String?
    var selectedCategories: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Configure and add UI elements
    }

    @objc private func continueButtonTapped() {
        // Save selected country and categories
        UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        UserDefaults.standard.set(selectedCategories, forKey: "selectedCategories")
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        
        // Navigate to the main screen
        let mainVC = MainViewController()
        navigationController?.pushViewController(mainVC, animated: true)
    }
}
