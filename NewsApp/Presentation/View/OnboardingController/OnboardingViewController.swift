import UIKit

class OnboardingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    // UI elements
    let countryPicker = UIPickerView()
    let categoriesTableView = UITableView()
    let continueButton = UIButton(type: .system)
    
    var selectedCountry: String?
    var selectedCategories: [String] = []
    let availableCountries = ["us", "uk", "fr", "de"]
    let availableCategories = ["business", "entertainment", "general", "health", "science", "sports", "technology"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Configure country picker
        countryPicker.translatesAutoresizingMaskIntoConstraints = false
        countryPicker.delegate = self
        countryPicker.dataSource = self
        view.addSubview(countryPicker)
        
        // Configure categories table view
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        view.addSubview(categoriesTableView)
        
        // Configure continue button
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            countryPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            countryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            countryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            categoriesTableView.topAnchor.constraint(equalTo: countryPicker.bottomAnchor, constant: 20),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoriesTableView.heightAnchor.constraint(equalToConstant: 200),
            
            continueButton.topAnchor.constraint(equalTo: categoriesTableView.bottomAnchor, constant: 20),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func continueButtonTapped() {
        // Save selected country and categories
        UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        UserDefaults.standard.set(selectedCategories, forKey: "selectedCategories")
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        
        // Navigate to the main screen
        let apiService = APIService()
        let repository = NewsRepositoryImpl(apiService: apiService)
        let fetchHeadlinesUseCase = FetchHeadlinesUseCase(repository: repository)
        let mainViewModel = MainViewModel(fetchHeadlinesUseCase: fetchHeadlinesUseCase)
        let mainVC = MainViewController(viewModel: mainViewModel)
        navigationController?.pushViewController(mainVC, animated: true)
    }

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableCountries.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableCountries[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = availableCountries[row]
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableCategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = availableCategories[indexPath.row]
        cell.accessoryType = selectedCategories.contains(availableCategories[indexPath.row]) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = availableCategories[indexPath.row]
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
