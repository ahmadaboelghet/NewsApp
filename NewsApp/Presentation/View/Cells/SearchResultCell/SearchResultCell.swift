//
//  SearchResultCell.swift
//  NewsApp
//
//  Created by Ahmad Aboelghet on 07/06/2024.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    // UI elements
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let resultImageView = UIImageView()
    let sourceLabel = UILabel()
    let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Configure titleLabel
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Configure dateLabel
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        // Configure resultImageView
        resultImageView.contentMode = .scaleAspectFill
        resultImageView.clipsToBounds = true
        resultImageView.layer.cornerRadius = 8
        resultImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultImageView)

        // Configure sourceLabel
        sourceLabel.font = UIFont.systemFont(ofSize: 12)
        sourceLabel.textColor = .gray
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sourceLabel)

        // Configure descriptionLabel
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textColor = .gray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // Set constraints
        NSLayoutConstraint.activate([
            resultImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            resultImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            resultImageView.widthAnchor.constraint(equalToConstant: 80),
            resultImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: resultImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: resultImageView.trailingAnchor, constant: 8),

            sourceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            sourceLabel.leadingAnchor.constraint(equalTo: resultImageView.trailingAnchor, constant: 8),

            descriptionLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: resultImageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with article: Article) {
        titleLabel.text = article.title
        dateLabel.text = article.publishedAt
        sourceLabel.text = article.source?.name
        descriptionLabel.text = article.description
        if let url = URL(string: article.urlToImage ?? "") {
            resultImageView.loadImage(from: url)
        }
    }
}
