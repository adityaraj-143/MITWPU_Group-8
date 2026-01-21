//
//  HomeLayout.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit


// MARK: - Layout
extension ViewController {
    
    func generateLayout() -> UICollectionViewLayout {
        
        UICollectionViewCompositionalLayout { sectionIndex, env in
            
            let sectionHeaderItem: NSCollectionLayoutBoundarySupplementaryItem = {
                let size = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(30)
                )
                return NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: size,
                    elementKind: "header-kind",
                    alignment: .top
                )
            }()
            
            switch sectionIndex {
                
            case 0: // Greeting
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(50)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(50)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: -30, leading: 30, bottom: 10, trailing: 30)
                return section
                
            case 1: // Today Exercise
                return Self.makeFullWidthSection(height: 140, top: 0, bottom: 15)
                
            case 2: // Recommended
                let section = Self.makeHorizontalSection(
                    height: 100,
                    itemWidth: 156
                )
                section.boundarySupplementaryItems = [sectionHeaderItem]
                return section
                
            case 3: // Tests
                let section = Self.makeTestsSection(
                    height: 95,
                    itemWidth: 168
                )
                section.boundarySupplementaryItems = [sectionHeaderItem]
                return section
                
            case 4: // Blink Rate (example using bold header)
                let section = Self.makeFullWidthSection(height: 165, top: 0, bottom: 15)
                section.boundarySupplementaryItems = [sectionHeaderItem]
                return section
                
            case 5: // Last Exercise
                return Self.makeFullWidthSection(height: 165, top: 0, bottom: 15)
                
            case 6: // Last Test
                return Self.makeFullWidthSection(height: 216, top: 0, bottom: 40)
                
            default:
                return nil
            }
        }
    }
    
    
    static func makeFullWidthSection(
        height: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0
    ) -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(height)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: width == 0 ? .fractionalWidth(1) : .absolute(width),
                heightDimension: .absolute(height)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: top, leading: 20, bottom: bottom, trailing: 20)
        return section
    }
    
    static func makeHorizontalSection(
        height: CGFloat,
        itemWidth: CGFloat
    ) -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .absolute(itemWidth),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(height)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 5, leading: 15, bottom: 10, trailing: 15)
        section.contentInsetsReference = .layoutMargins
        return section
    }
    
    
    static func makeTestsSection(
        height: CGFloat,
        itemWidth: CGFloat
    ) -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(height)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(height)
            ),
            repeatingSubitem: item,
            count: 2
        )
        
        group.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 5, leading: 15, bottom: 10, trailing: 15)
        section.contentInsetsReference = .layoutMargins
        
        return section
    }
    
}

