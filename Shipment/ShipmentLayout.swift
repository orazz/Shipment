//
//  ShipmentLayout.swift
//  Shipment
//
//  Created by Atakishiyev Orazdurdy on 10/15/16.
//  Copyright © 2016 Veriloft. All rights reserved.
//

import UIKit

struct ShipmentLayoutConst {
    static let maxYOffset: CGFloat = -10
    static let minZoomLevel: CGFloat = 0.9
    static let minAlpha: CGFloat = 0.5
}

class ShipmentLayout: UICollectionViewFlowLayout {
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // init setup
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        //self.itemSize = CGSize(width: 290, height: 424)
    }
    
    // MARK: -
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAtts = super.layoutAttributesForElements(in: rect) else { return nil }
        // we copy layout attributes here to avoid collection view cache diff warning
        let modifiedLayoutAtts = Array(NSArray(array: layoutAtts, copyItems: true)) as! [UICollectionViewLayoutAttributes]
        let visibleRect = CGRect(origin: self.collectionView!.contentOffset, size: self.collectionView!.bounds.size)
        let activeWidth = self.collectionView!.bounds.size.width
        // adjust zoom of each cell so that the center cell is at 1x, while surrounding cells are as low as 0.9x depending on distance from center
        for attributes in modifiedLayoutAtts {
            if attributes.frame.intersects(visibleRect) {
                let distance = visibleRect.midX - attributes.center.x
                let normalDistance = distance / activeWidth
                if (abs(distance) < activeWidth) {
                    // translate
                    let yOffset = ShipmentLayoutConst.maxYOffset * (1-abs(normalDistance))
                    let offsetTransform = CATransform3DMakeTranslation(0, yOffset, 0)
                    // scale
                    let zoom = ShipmentLayoutConst.minZoomLevel + (1-ShipmentLayoutConst.minZoomLevel)*(1-abs(normalDistance))
                    attributes.transform3D = CATransform3DScale(offsetTransform, zoom, zoom, 1)
                    attributes.zIndex = 1
                    // opacity
                    let alpha = ShipmentLayoutConst.minAlpha + (1-ShipmentLayoutConst.minAlpha)*(1-abs(normalDistance))
                    attributes.alpha = alpha
                }
            }
        }
        
        return modifiedLayoutAtts
    }
    
}
