//
//  DesignSystem.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import UIKit

enum DesignSystem {
    enum Font {
        // Pages have the largest font
        static let pageTitle = UIFont.systemFont(ofSize: 24, weight: .bold)
        static let pageSubtitle = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        // Sections have medium font, decreasing with nesting
        static let sectionTitle = UIFont.systemFont(ofSize: 22, weight: .semibold)
        static let nestedSectionTitle = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let deepNestedSectionTitle = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let sectionSubtitle = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        // Questions have smallest font
        static let questionTitle = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let questionSubtitle = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    enum Layout {
        static let sectionHeight: CGFloat = 120
        static let textHeight: CGFloat = 100
        static let imageHeight: CGFloat = 280
        
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let iconSize: CGFloat = 28
        
        static let sectionCornerRadius: CGFloat = 32
        static let contentCornerRadius: CGFloat = 24
        static let imageCornerRadius: CGFloat = 16
        
        static let cellSpacing: CGFloat = 12
    }
    
    enum Color {
        // First level color (dark navy)
        static let firstLevelBackground = UIColor(red: 35/255, green: 41/255, blue: 70/255, alpha: 1.0)
        static let firstLevelText = UIColor.white
        static let firstLevelSubtitle = UIColor.white.withAlphaComponent(0.7)
        
        // Nested item colors (light blue)
        static let nestedBackground = UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0)
        static let nestedText = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        static let nestedSubtitle = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
        
        static func backgroundFor(itemType: Item.ItemType, nestingLevel: Int) -> UIColor {
            // Only top-level sections and pages use the dark navy background
            if nestingLevel == 0 && (itemType == .section || itemType == .page) {
                return firstLevelBackground
            }
            // All other items use the light background
            return nestedBackground
        }
        
        static func titleColorFor(itemType: Item.ItemType, nestingLevel: Int) -> UIColor {
            // Only top-level sections and pages use white text
            if nestingLevel == 0 && (itemType == .section || itemType == .page) {
                return firstLevelText
            }
            return nestedText
        }
        
        static func subtitleColorFor(itemType: Item.ItemType, nestingLevel: Int) -> UIColor {
            // Only top-level sections and pages use white subtitle
            if nestingLevel == 0 && (itemType == .section || itemType == .page) {
                return firstLevelSubtitle
            }
            return nestedSubtitle
        }
    }
} 
