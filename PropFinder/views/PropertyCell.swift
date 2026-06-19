//
//  PropertyCell.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 19/06/2026.
//


import UIKit

/// A completely custom, programmatic TableViewCell.
/// Senior Detail: We avoid XIBs/Storyboards to guarantee performant view reuse,
/// elimination of hidden runtime XML parsing, and clean git merge resolutions.
final class PropertyCell: UITableViewCell {
    
    // MARK: - Core UI Components
    
    private let propertyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        // Since we enforce programmatic layouts, failing hard here prevents a developer
        // from accidentally trying to use this cell via an interface builder.
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Reuse Polish
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Prevents UI flashing or old images showing up on reused rows during fast scrolling
        propertyImageView.image = nil
        priceLabel.text = nil
        titleLabel.text = nil
        detailsLabel.text = nil
    }
    
    // MARK: - Setup Layout Pipeline
    
    private func setupViews() {
        selectionStyle = .none
        
        // Always add views to the contentView container, NEVER directly to self
        contentView.addSubview(propertyImageView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 1. ImageView Constraints (Left-anchored, square aspect ratio)
            propertyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            propertyImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            propertyImageView.widthAnchor.constraint(equalToConstant: 80),
            propertyImageView.heightAnchor.constraint(equalToConstant: 80),
            // Senior Detail: Dynamic height calculation relies on top/bottom pinning
            propertyImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            propertyImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // 2. Price Label Constraints (Top right of the image view)
            priceLabel.leadingAnchor.constraint(equalTo: propertyImageView.trailingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.topAnchor.constraint(equalTo: propertyImageView.topAnchor),
            
            // 3. Title Label Constraints (Directly beneath the price)
            titleLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            
            // 4. Details Label Constraints (Bottom of the stack)
            detailsLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: propertyImageView.bottomAnchor)
        ])
    }
    
    
    // MARK: - Configuration Engine
        
        func configure(with property: Property) {
            // 1. Format currency precisely for Dubizzle Labs standards
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "AED"
            formatter.maximumFractionDigits = 0
            
            if let formattedPrice = formatter.string(from: NSNumber(value: property.price)) {
                priceLabel.text = formattedPrice
            } else {
                priceLabel.text = "\(property.price)"
            }
            
            titleLabel.text = property.title
            detailsLabel.text = "🛏️ \(property.bedrooms) Beds  •  🛁 \(property.bathrooms) Baths  •  📍 \(property.location)"
            
            // 2. LAZY IMAGE DOWNLOADING OPTIMIZATION
            // Set a clean placeholder image first to handle the loading state
            propertyImageView.image = UIImage(systemName: "building.2.fill")
            propertyImageView.tintColor = .systemGray4
            
            // Fallback guard: If url is empty (like our seeded dummy entries), skip network loading
            guard !property.imageUrl.isEmpty else { return }
            
            // Spawn a structured asynchronous concurrency task to pull the image off the main thread
            Task { [weak self] in
                guard let self = self else { return }
                
                // Define the visual box size we want to downsample to (80x80 points)
                let targetSize = CGSize(width: 80, height: 80)
                
                // Call our utility engine to fetch the image asset safely
                if let downloadedImage = await ImageLoader.shared.loadImage(from: property.imageUrl, targetSize: targetSize) {
                    // Ensure the UI layout update hops right back onto the Main Thread
                    await MainActor.run {
                        self.propertyImageView.image = downloadedImage
                    }
                }
            }
        }
}


