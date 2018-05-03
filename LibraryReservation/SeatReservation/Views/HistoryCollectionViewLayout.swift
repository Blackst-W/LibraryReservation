//
//  HistoryCollectionViewLayout.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class HistoryCollectionViewLayout: UICollectionViewLayout {
    var itemCount = 0
    var layoutArray = [UICollectionViewLayoutAttributes]()
    let padding: CGFloat = 16
    let cellGap: CGFloat = 4
    let maxWidth: CGFloat = 500
    var cellWidth: CGFloat {
        let width = collectionView!.frame.width - padding * 2 - cellGap * 2
        return min(maxWidth, width)
    }
    
    let cellHeight: CGFloat = 124
    
    var contentInsets: UIEdgeInsets {
        return collectionView!.contentInset
    }
    
    override var collectionViewContentSize: CGSize {
        let width = (cellWidth + 2 * cellGap) * CGFloat(itemCount) + padding * 2
        return CGSize(width: width, height: cellHeight + 2 * cellGap)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        for layoutAttributes in layoutArray {
            if rect.intersects(layoutAttributes.frame) {
                result.append(layoutAttributes)
            }
        }
        return result
    }
    
    override func prepare() {
        super.prepare()
        layoutArray.removeAll()
        guard let collectionView = collectionView else {
            return
        }
        itemCount = collectionView.numberOfItems(inSection: 0)
        guard itemCount > 0 else {
            return
        }
        let width = cellWidth
        let height = cellHeight
        let gap = cellGap
        for index in 0..<itemCount {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attributes.frame = CGRect(x: (width + gap * 2) * CGFloat(index) + gap + padding, y: gap, width: width, height: height)
            layoutArray.append(attributes)
        }
        
    }
    
}
