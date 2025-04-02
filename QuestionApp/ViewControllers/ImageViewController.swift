//
//  ImageViewController.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import UIKit

class ImageViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var originalImageFrame: CGRect = .zero
    private var image: UIImage?
    private var sourceImageView: UIImageView?
    private var imageViewTopConstraint: NSLayoutConstraint?
    private var imageViewLeadingConstraint: NSLayoutConstraint?
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    
    init(image: UIImage?, sourceImageView: UIImageView, originalFrame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        self.sourceImageView = sourceImageView
        self.originalImageFrame = originalFrame
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sourceImageView?.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sourceImageView?.alpha = 1
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        // Add background view
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add image view with constraints
        view.addSubview(imageView)
        imageView.image = image
        
        // Initial constraints matching the original frame
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: originalImageFrame.minY)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: originalImageFrame.minX)
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: originalImageFrame.width)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: originalImageFrame.height)
        
        NSLayoutConstraint.activate([
            imageViewTopConstraint!,
            imageViewLeadingConstraint!,
            imageViewWidthConstraint!,
            imageViewHeightConstraint!
        ])
        
        // Add close button
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    private func animateIn() {
        let targetSize = calculateTargetSize()        
        // Deactivate current constraints
        NSLayoutConstraint.deactivate([
            imageViewTopConstraint!,
            imageViewLeadingConstraint!,
            imageViewWidthConstraint!,
            imageViewHeightConstraint!
        ])
        
        // Setup new center constraints
        imageViewTopConstraint = imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        imageViewLeadingConstraint = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: targetSize.width)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: targetSize.height)
        
        NSLayoutConstraint.activate([
            imageViewTopConstraint!,
            imageViewLeadingConstraint!,
            imageViewWidthConstraint!,
            imageViewHeightConstraint!
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
            self.backgroundView.alpha = 0.9
            self.closeButton.alpha = 1
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        // Deactivate current constraints
        NSLayoutConstraint.deactivate([
            imageViewTopConstraint!,
            imageViewLeadingConstraint!,
            imageViewWidthConstraint!,
            imageViewHeightConstraint!
        ])
        
        // Setup original frame constraints
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: originalImageFrame.minY)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: originalImageFrame.minX)
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: originalImageFrame.width)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: originalImageFrame.height)
        
        NSLayoutConstraint.activate([
            imageViewTopConstraint!,
            imageViewLeadingConstraint!,
            imageViewWidthConstraint!,
            imageViewHeightConstraint!
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
            self.backgroundView.alpha = 0
            self.closeButton.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
    private func calculateTargetSize() -> CGSize {
        guard let image = image else { return .zero }
        
        let screenSize = view.bounds.size
        let screenAspect = screenSize.width / screenSize.height
        let imageAspect = image.size.width / image.size.height
        
        var targetSize = CGSize.zero
        
        if imageAspect > screenAspect {
            // Image is wider than screen
            targetSize.width = screenSize.width - 32 // 16pt padding on each side
            targetSize.height = targetSize.width / imageAspect
        } else {
            // Image is taller than screen
            targetSize.height = screenSize.height - 100 // Allow for some padding
            targetSize.width = targetSize.height * imageAspect
        }
        
        return targetSize
    }
    
    private func calculateTargetCenter(for size: CGSize) -> CGPoint {
        return CGPoint(
            x: view.bounds.midX,
            y: view.bounds.midY
        )
    }
    
    @objc private func closeButtonTapped() {
        animateOut { [weak self] in
            self?.dismiss(animated: false)
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        closeButtonTapped()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // Update constraints instead of frame
            imageViewTopConstraint?.constant += translation.y
            imageViewLeadingConstraint?.constant += translation.x
            gesture.setTranslation(.zero, in: view)
            
        case .ended:
            let shouldDismiss = abs(velocity.y) > 1000 || abs(imageView.center.y - view.center.y) > view.bounds.height / 4
            
            if shouldDismiss {
                animateOut { [weak self] in
                    self?.dismiss(animated: false)
                }
            } else {
                animateIn()
            }
            
        default:
            break
        }
    }
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let scale = gesture.scale
            imageViewWidthConstraint?.constant *= scale
            imageViewHeightConstraint?.constant *= scale
            gesture.scale = 1.0
            
        case .ended:
            animateIn()
            
        default:
            break
        }
    }
} 
