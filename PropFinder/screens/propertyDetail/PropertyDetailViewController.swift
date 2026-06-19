//
//  PropertyDetailViewController.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 19/06/2026.
//

import UIKit

// MARK: - ViewModel Implementation
/// Holds the internal business state for a single unique property asset.
final class PropertyDetailViewModel {
    let property: Property
    
    init(property: Property) {
        self.property = property
    }
}

// MARK: - ViewController Layout Implementation
/// Renders the deep detailed specs of a selected property inside a programmatic scroll container.
final class PropertyDetailViewController: UIViewController {
    
    private let viewModel: PropertyDetailViewModel
    
    // MARK: - UI Scroll Subcomponents
    
    /// The primary wrapper scroll container to manage scrolling behavior.
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    /// The master stack view that layout constraints rely on to prevent scroll content collapse.
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "building.2.fill")
        imageView.tintColor = .systemGray4
        return imageView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0 // Allows fluid word wrapping on thin devices
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "This premium property offers an outstanding floor plan with modern layouts, high-quality finishes, and easy transit links. Located in a sought-after neighborhood, it represents a remarkable lifestyle choice or investment opportunity."
        return label
    }()
    
    // MARK: - Initializer
    init(viewModel: PropertyDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureData()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Property Details"
        navigationItem.largeTitleDisplayMode = .never
        
        // Hierarchy stack: View -> ScrollView -> ContentView -> UI Components
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(mainImageView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 1. ScrollView Frame Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 2. ContentView Scroll Mechanics Constraints
            // Crucial: Pin to contentLayoutGuide to determine scroll boundaries, and match width to frameLayoutGuide
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // 3. UI Asset Components Constraints
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65), // Maintain 16:9 look
            
            priceLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 20),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            // Senior Detail: The absolute bottom constraint inside your content view tells the scroll view where it ends
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func configureData() {
        let property = viewModel.property
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AED"
        formatter.maximumFractionDigits = 0
        
        priceLabel.text = formatter.string(from: NSNumber(value: property.price)) ?? "\(property.price)"
        titleLabel.text = property.title
    }
}
