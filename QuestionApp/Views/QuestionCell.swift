//
//  IconConfiguration.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//
import UIKit
import Alamofire

// MARK: - ItemType UI Configuration
private extension Item.ItemType {
    var iconConfiguration: IconConfiguration? {
        let config = UIImage.SymbolConfiguration(
            pointSize: DesignSystem.Layout.iconSize,
            weight: .light
        )
        
        switch self {
        case .section:
            return IconConfiguration(
                symbolName: "folder.fill",
                configuration: config,
                subtitle: "Section"
            )
        case .page:
            return IconConfiguration(
                symbolName: "doc",
                configuration: config,
                subtitle: "Page"
            )
        default:
            return nil
        }
    }
}

// MARK: - Supporting Types
private struct IconConfiguration {
    let symbolName: String
    let configuration: UIImage.SymbolConfiguration
    let subtitle: String
    
    var image: UIImage? {
        UIImage(systemName: symbolName, withConfiguration: configuration)
    }
}

protocol QuestionCellDelegate: AnyObject {
    func questionCell(_ cell: QuestionCell, didTapImageAt imageFrame: CGRect)
    func questionCell(_ cell: QuestionCell, didTapExpandFor item: Item)
}

// MARK: - QuestionCell
class QuestionCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var expandButton: UIButton!
    @IBOutlet  weak var contentImageView: UIImageView!
    @IBOutlet private weak var contentImageHeight: NSLayoutConstraint!
    @IBOutlet private weak var stackView: UIStackView!
    
    // MARK: - Properties
    private var isSection: Bool = false
    private var currentItem: Item?
    private var currentItemType: Item.ItemType = .text
    weak var delegate: QuestionCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        typeImageView.image = nil
        contentImageView.image = nil
        cardView.transform = .identity
        currentItem = nil
    }
    
    // MARK: - Configuration
    func configure(with item: Item, nestingLevel: Int, isExpanded: Bool = false) {
        currentItem = item
        isSection = item.itemType == .section && nestingLevel == 0
        currentItemType = item.itemType
        
        configureLayout(for: item.itemType)
        configureTitleLabel(with: item.title, nestingLevel: nestingLevel)
        configureCardView(for: item, nestingLevel: nestingLevel)
        configureTypeIcon(item.itemType, nestingLevel: nestingLevel)
        configureSubtitleLabel(nestingLevel: nestingLevel)
        configureExpandButton(isHidden: item.items?.isEmpty != false, isExpanded: isExpanded, nestingLevel: nestingLevel)
        
        if item.itemType == .image {
            configureImageContent(with: item)
            setupImageTapGesture()
        } else {
            contentImageView.isHidden = true
            contentImageHeight.constant = 0
        }
        
        // Apply indentation for nested items with increased spacing
        if nestingLevel > 0 {
            let indentation: CGFloat = 8 // Increased indentation for better hierarchy
            cardView.transform = CGAffineTransform(translationX: CGFloat(nestingLevel) * indentation, y: 0)
        } else {
            cardView.transform = .identity
        }
    }
    
    // MARK: - Private Setup
    private func setupUI() {
        setupCardStyle()
        setupTypeIcon()
        setupStackView()
        setupContentImage()
        setupLabels()
    }
    
    private func setupCardStyle() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.clipsToBounds = true
        selectionStyle = .none
    }
    
    private func setupTypeIcon() {
        typeImageView.contentMode = .scaleAspectFit
        typeImageView.clipsToBounds = true
        // Set a fixed width to maintain consistent spacing even when hidden
        typeImageView.widthAnchor.constraint(equalToConstant: DesignSystem.Layout.iconSize).isActive = true
        typeImageView.heightAnchor.constraint(equalToConstant: DesignSystem.Layout.iconSize).isActive = true
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fill
    }
    
    private func setupContentImage() {
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        contentImageView.layer.cornerRadius = DesignSystem.Layout.imageCornerRadius
        contentImageView.isHidden = true
    }
    
    private func setupLabels() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setupImageTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        contentImageView.addGestureRecognizer(tapGesture)
        contentImageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Private Configuration
    private func configureLayout(for itemType: Item.ItemType) {
        switch itemType {
        case .image:
            contentImageView.isHidden = false
            contentImageHeight.constant = 180
        default:
            contentImageView.isHidden = true
            contentImageHeight.constant = 0
        }
    }
    
    private func configureTitleLabel(with text: String, nestingLevel: Int) {
        titleLabel.text = text
        
        // Configure font based on type and nesting
        switch currentItemType {
        case .page:
            titleLabel.font = DesignSystem.Font.pageTitle
        case .section:
            switch nestingLevel {
            case 0:
                titleLabel.font = DesignSystem.Font.sectionTitle
            case 1:
                titleLabel.font = DesignSystem.Font.nestedSectionTitle
            default:
                titleLabel.font = DesignSystem.Font.deepNestedSectionTitle
            }
        default:
            titleLabel.font = DesignSystem.Font.questionTitle
        }
        
        titleLabel.textColor = DesignSystem.Color.titleColorFor(itemType: currentItemType, nestingLevel: nestingLevel)
        titleLabel.numberOfLines = 0
    }
    
    private func configureCardView(for item: Item, nestingLevel: Int) {
        cardView.backgroundColor = DesignSystem.Color.backgroundFor(itemType: item.itemType, nestingLevel: nestingLevel)
        
        // Only top-level sections and pages get the larger corner radius
        cardView.layer.cornerRadius = (nestingLevel == 0 && (item.itemType == .section || item.itemType == .page)) ?
            DesignSystem.Layout.sectionCornerRadius :
            DesignSystem.Layout.contentCornerRadius
        
        // Ensure proper layout for first-level items
        if nestingLevel == 0 && (item.itemType == .section || item.itemType == .page) {
            cardView.layoutIfNeeded()
        }
    }
    
    private func configureTypeIcon(_ itemType: Item.ItemType, nestingLevel: Int) {
        if let iconConfig = itemType.iconConfiguration {
            typeImageView.isHidden = false
            typeImageView.image = iconConfig.image
            typeImageView.tintColor = DesignSystem.Color.titleColorFor(itemType: itemType, nestingLevel: nestingLevel)
            typeImageView.alpha = 1
        } else {
            typeImageView.isHidden = false // Keep it visible but transparent
            typeImageView.image = nil
            typeImageView.alpha = 0 // Make it transparent instead of hiding
        }
        
        // Remove the spacing adjustment since we're maintaining consistent layout
        if let headerStack = typeImageView.superview as? UIStackView {
            headerStack.spacing = 12 // Maintain consistent spacing
        }
    }
    
    private func configureSubtitleLabel(nestingLevel: Int) {
        // Configure subtitle font based on type
        switch currentItemType {
        case .page:
            subtitleLabel.font = DesignSystem.Font.pageSubtitle
        case .section:
            subtitleLabel.font = DesignSystem.Font.sectionSubtitle
        default:
            subtitleLabel.font = DesignSystem.Font.questionSubtitle
        }
        
        subtitleLabel.textColor = DesignSystem.Color.subtitleColorFor(itemType: currentItemType, nestingLevel: nestingLevel)
        subtitleLabel.text = currentItemType.iconConfiguration?.subtitle
        subtitleLabel.isHidden = false // Ensure subtitle is always visible
    }
    
    private func configureExpandButton(isHidden: Bool, isExpanded: Bool, nestingLevel: Int) {
        expandButton.isHidden = isHidden
        if !isHidden {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let imageName = "chevron.down"
            expandButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
            expandButton.tintColor = DesignSystem.Color.titleColorFor(itemType: currentItemType, nestingLevel: nestingLevel)
            
            // Ensure the button is properly sized and positioned
            expandButton.contentMode = .center
            expandButton.imageView?.contentMode = .scaleAspectFit
            
            // Set the initial transform without animation if needed
            if expandButton.transform == .identity && isExpanded {
                expandButton.transform = CGAffineTransform(rotationAngle: .pi)
            } else if expandButton.transform != .identity && !isExpanded {
                expandButton.transform = .identity
            }
        }
    }
    
    private func configureImageContent(with item: Item) {
        if let imageUrl = item.src {
            loadImage(from: imageUrl)
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        AF.request(url).responseData { [weak self] response in
            if case .success(let data) = response.result,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.contentImageView.image = image
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func expandButtonTapped(_ sender: UIButton) {
        guard let item = currentItem else { return }
        delegate?.questionCell(self, didTapExpandFor: item)
    }
    
    @objc private func handleImageTap() {
        let imageFrame = contentImageView.convert(contentImageView.bounds, to: nil)
        delegate?.questionCell(self, didTapImageAt: imageFrame)
    }
}

