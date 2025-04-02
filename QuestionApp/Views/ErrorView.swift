//
//  ErrorView.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import UIKit
import Alamofire

class ErrorView: UIView {
    
    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        imageView.image = UIImage(systemName: "exclamationmark.triangle", withConfiguration: config)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Oops!"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(red: 64/255, green: 95/255, blue: 255/255, alpha: 1.0)
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try Again", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 64/255, green: 95/255, blue: 255/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        return button
    }()
    
    var retryAction: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(errorImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(detailLabel)
        stackView.addArrangedSubview(retryButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
            
            errorImageView.heightAnchor.constraint(equalToConstant: 60),
            errorImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with error: Error) {
        messageLabel.text = "Something went wrong while loading the polls."
        
        if let urlError = error as? URLError {
            detailLabel.text = "Network Error: Please check your internet connection"
        } else if let afError = error as? AFError {
            detailLabel.text = "Connection Error: Unable to reach the server"
        } else {
            detailLabel.text = error.localizedDescription
        }
    }
    
    // MARK: - Actions
    @objc private func retryButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.retryButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.retryButton.transform = .identity
            }
            self.retryAction?()
        }
    }
} 
