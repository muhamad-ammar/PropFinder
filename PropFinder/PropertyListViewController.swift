import CoreData
import UIKit

/// The main view controller responsible for displaying the property listing screen.
/// Senior Detail: This class is purely "dumb" regarding data logic. It simply listens
/// to the ViewModel's state updates and maps them onto the programmatic UIKit views.
final class PropertyListViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: PropertyListViewModel
    private var dataSource: [Property] = []

    // MARK: - Programmatic UI Components

    /// The programmatic TableView instance.
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBackground
        // Register our custom cell class manually with a unique reuse identifier
        table.register(
            PropertyCell.self,
            forCellReuseIdentifier: "PropertyCell"
        )
        return table
    }()

    /// Standard pull-to-refresh control to trigger a clean repository sync.
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()

    /// A central loading spinner shown during the initial cold boot.
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initializer
    /// Force dependency injection via initializer. The app cannot launch this screen without a valid state engine.
    init(viewModel: PropertyListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupConstraints()
        bindViewModel()
        // ---- TEMPORARY SEEDING FOR PHASE 2 VISUAL CHECK ----
        seedMockDataIfNeeded()
        // ----------------------------------------------------
 
        // Initial data fetch trigger
        viewModel.loadProperties()
    }

    // MARK: - Layout Configuration

    private func setupNavigation() {
        title = "Verified Properties"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground

        // Delegate and DataSource assignments for the table framework
        tableView.delegate = self
        tableView.dataSource = self

        // Attach the pull-to-refresh interaction
        refreshControl.addTarget(
            self,
            action: #selector(handleRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl

        // Add layouts to hierarchical view tree
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Pin the table view perfectly to fill all edges of the screen
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Center the loading spinner directly in the middle of the layout window
            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
        ])
    }

    // MARK: - MVVM State Binding Engine

    private func bindViewModel() {
        // Capture the ViewModel state stream.
        // [weak self] is absolutely required here to break the strong reference retain cycle.
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .idle:
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()

            case .loading:
                // Only show central spinner if pull-to-refresh isn't already active
                if !self.refreshControl.isRefreshing {
                    self.activityIndicator.startAnimating()
                }

            case .success(let properties):
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                // Update local storage data source container and redraw table rows
                self.dataSource = properties
                self.tableView.reloadData()

            case .empty:
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.dataSource = []
                self.tableView.reloadData()
            // Senior Note: In real production, you would display a clean empty-state background view here.

            case .error(let message):
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.showErrorAlert(message: message)
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.loadProperties()
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Sync Warning",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

/// Injects a few local properties if Core Data is completely empty so we can verify the UI layout.
private func seedMockDataIfNeeded() {
    let context = CoreDataStack.shared.mainContext
    let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()

    do {
        let count = try context.count(for: request)
        // Only seed data if our database file is fresh and has 0 properties
        guard count == 0 else { return }

        let mock1 = PropertyEntity(context: context)
        mock1.id = "1"
        mock1.title = "Luxury 2BR Apartment with Marina View"
        mock1.price = 2_450_000
        mock1.location = "Dubai Marina, Dubai"
        mock1.bedrooms = 2
        mock1.bathrooms = 2
        mock1.imageUrl = ""
        mock1.isFavorite = false
        mock1.createdAt = Date()

        let mock2 = PropertyEntity(context: context)
        mock2.id = "2"
        mock2.title = "Modern Downtown Penthouse"
        mock2.price = 5_800_000
        mock2.location = "Downtown Dubai, Dubai"
        mock2.bedrooms = 3
        mock2.bathrooms = 4
        mock2.imageUrl = ""
        mock2.isFavorite = true
        mock2.createdAt = Date().addingTimeInterval(-3600)  // 1 hour ago

        let mock3 = PropertyEntity(context: context)
        mock3.id = "3"
        mock3.title = "Cozy Family Villa with Private Pool"
        mock3.price = 8_900_000
        mock3.location = "Arabian Ranches, Dubai"
        mock3.bedrooms = 4
        mock3.bathrooms = 5
        mock3.imageUrl = ""
        mock3.isFavorite = false
        mock3.createdAt = Date().addingTimeInterval(-7200)  // 2 hours ago

        let mock4 = PropertyEntity(context: context)
        mock4.id = "4"
        mock4.title = "Cozy Family Villa with Private Pool"
        mock4.price = 8_900_000
        mock4.location = "Arabian Ranches, Dubai"
        mock4.bedrooms = 4
        mock4.bathrooms = 5
        mock4.imageUrl = ""
        mock4.isFavorite = false
        mock4.createdAt = Date().addingTimeInterval(-7200)

        let mock5 = PropertyEntity(context: context)
        mock5.id = "5"
        mock5.title = "Cozy Family Villa with Private Pool"
        mock5.price = 8_900_000
        mock5.location = "Arabian Ranches, Dubai"
        mock5.bedrooms = 4
        mock5.bathrooms = 5
        mock5.imageUrl = ""
        mock5.isFavorite = false
        mock5.createdAt = Date().addingTimeInterval(-7200)

        let mock6 = PropertyEntity(context: context)
        mock6.id = "6"
        mock6.title = "Modern 1BR Smart Apartment"
        mock6.price = 1_150_000
        mock6.location = "Jumeirah Village Circle, Dubai"
        mock6.bedrooms = 1
        mock6.bathrooms = 2
        mock6.imageUrl = ""
        mock6.isFavorite = true
        mock6.createdAt = Date().addingTimeInterval(-18000)  // 5 hours ago

        let mock7 = PropertyEntity(context: context)
        mock7.id = "7"
        mock7.title = "Ultra-Luxury 5BR Golf Course Villa"
        mock7.price = 15_500_000
        mock7.location = "Dubai Hills Estate, Dubai"
        mock7.bedrooms = 5
        mock7.bathrooms = 6
        mock7.imageUrl = ""
        mock7.isFavorite = false
        mock7.createdAt = Date().addingTimeInterval(-21600)  // 6 hours ago

        let mock8 = PropertyEntity(context: context)
        mock8.id = "8"
        mock8.title = "Chic 2BR Duplex near Metro Station"
        mock8.price = 1_850_000
        mock8.location = "Al Furjan, Dubai"
        mock8.bedrooms = 2
        mock8.bathrooms = 3
        mock8.imageUrl = ""
        mock8.isFavorite = false
        mock8.createdAt = Date().addingTimeInterval(-25200)  // 7 hours ago

        let mock9 = PropertyEntity(context: context)
        mock9.id = "9"
        mock9.title = "Upgraded 3BR Townhouse with Garden"
        mock9.price = 3_100_000
        mock9.location = "Damac Hills 2, Dubai"
        mock9.bedrooms = 3
        mock9.bathrooms = 4
        mock9.imageUrl = ""
        mock9.isFavorite = false
        mock9.createdAt = Date().addingTimeInterval(-28800)  // 8 hours ago

        let mock10 = PropertyEntity(context: context)
        mock10.id = "10"
        mock10.title = "Premium Waterfront 2BR Penthouse"
        mock10.price = 6_200_000
        mock10.location = "Palm Jumeirah, Dubai"
        mock10.bedrooms = 2
        mock10.bathrooms = 3
        mock10.imageUrl = ""
        mock10.isFavorite = true
        mock10.createdAt = Date().addingTimeInterval(-32400)  // 9 hours ago

        let mock11 = PropertyEntity(context: context)
        mock11.id = "11"
        mock11.title = "Affordable Studio in Community Hub"
        mock11.price = 680000
        mock11.location = "Silicon Oasis, Dubai"
        mock11.bedrooms = 0  // Studio
        mock11.bathrooms = 1
        mock11.imageUrl = ""
        mock11.isFavorite = false
        mock11.createdAt = Date().addingTimeInterval(-36000)  // 10 hours ago

        let mock12 = PropertyEntity(context: context)
        mock12.id = "12"
        mock12.title = "Spacious 4BR Villa Close to Schools"
        mock12.price = 7_400_000
        mock12.location = "The Meadows, Dubai"
        mock12.bedrooms = 4
        mock12.bathrooms = 4
        mock12.imageUrl = ""
        mock12.isFavorite = false
        mock12.createdAt = Date().addingTimeInterval(-39600)  // 11 hours ago

        let mock13 = PropertyEntity(context: context)
        mock13.id = "13"
        mock13.title = "Elegant 1BR Apartment with Boulevard View"
        mock13.price = 1_600_000
        mock13.location = "Downtown Dubai, Dubai"
        mock13.bedrooms = 1
        mock13.bathrooms = 2
        mock13.imageUrl = ""
        mock13.isFavorite = false
        mock13.createdAt = Date().addingTimeInterval(-43200)  // 12 hours ago

        let mock14 = PropertyEntity(context: context)
        mock14.id = "14"
        mock14.title = "Cozy 2BR Green Community Apartment"
        mock14.price = 2_100_000
        mock14.location = "Motor City, Dubai"
        mock14.bedrooms = 2
        mock14.bathrooms = 2
        mock14.imageUrl = ""
        mock14.isFavorite = false
        mock14.createdAt = Date().addingTimeInterval(-46800)  // 13 hours ago

        try context.save()
        print("Database successfully seeded with mock properties.")
    } catch {
        print("Failed to seed mock properties: \(error.localizedDescription)")
    }
}

// MARK: - UITableViewDataSource & Delegate Protocols

extension PropertyListViewController: UITableViewDataSource, UITableViewDelegate
{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        // Dequeue our programmatic reusable cell casted safely
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PropertyCell",
                for: indexPath
            ) as? PropertyCell
        else {
            return UITableViewCell()
        }

        let property = dataSource[indexPath.row]
        cell.configure(with: property)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // Deselect row quickly for a premium tap-fade transition effect
        tableView.deselectRow(at: indexPath, animated: true)

        // 1. Identify the selected property value entity
        let selectedProperty = dataSource[indexPath.row]

        // 2. Initialize the programmatic targets
        let detailVM = PropertyDetailViewModel(property: selectedProperty)
        let detailVC = PropertyDetailViewController(viewModel: detailVM)

        // 3. Execute navigation push
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


