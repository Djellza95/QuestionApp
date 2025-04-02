//
//  Item.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import Foundation

// Base item that all types inherit from
struct Item: Codable, Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let items: [Item]?
    let src: String?
    
    enum CodingKeys: String, CodingKey {
        case type, title, items, src
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        items = try container.decodeIfPresent([Item].self, forKey: .items)
        src = try container.decodeIfPresent(String.self, forKey: .src)
    }
}

extension Item {
    var isExpandable: Bool {
        return items != nil
    }
    
    var itemType: ItemType {
        switch type {
        case "page":
            return .page
        case "section":
            return .section
        case "text":
            return .text
        case "image":
            return .image
        default:
            return .text
        }
    }
    
    enum ItemType {
        case page
        case section
        case text
        case image
    }
} 
