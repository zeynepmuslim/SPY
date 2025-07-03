//
//  CenteredFlowLayout.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.04.2025.
//


import UIKit

// Son satırdaki öğeleri ortala
class CenteredFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Önce süper sınıfın varsayılan özniteliklerini al.
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        // Güvenlik için kopyaları üzerinde çalış.
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        //        // --- DEBUG START ---
        //        print("--- CenteredFlowLayout: layoutAttributesForElements(in: \(rect)) ---")
        //        print("Incoming attributes count: \(attributes.count)")
        //        if let cv = collectionView {
        //            print("CollectionView bounds: \(cv.bounds)")
        //        }
        //        for attr in attributes where attr.representedElementCategory == .cell {
        //            print("  Incoming Attr [\(attr.indexPath.item)]: \(attr.frame)")
        //        }
        // --- DEBUG END ---
        
        // Öğeleri satırlara göre grupla.
        var rows = [[UICollectionViewLayoutAttributes]]()
        var currentRowY: CGFloat = -1 // Mevcut satırın Y koordinatını takip etmek için değişken. Başlangıçta geçersiz bir değer (-1).
        
        for attribute in attributes {
            if attribute.representedElementCategory == .cell {
                // Satırları belirlerken Y koordinatlarındaki küçük farkları tolere etmek için bir eşik değeri (1) kullanılır.
                // Eğer 'rows' boşsa veya mevcut özniteliğin Y'si bir önceki satırın Y'sinden anlamlı derecede (> 1) büyükse, yeni bir satır başlat.
                if rows.isEmpty || attribute.frame.origin.y > currentRowY + 1 { // Start new row if Y significantly increased
                    currentRowY = attribute.frame.origin.y
                    rows.append([attribute])
                } else {
                    // Add to the last existing row
                    rows[rows.count - 1].append(attribute)
                }
            }
        }
        
        // --- DEBUG START ---
        //        print("Grouped Rows: \(rows.count)")
        //        for (index, row) in rows.enumerated() {
        //            let sortedRow = row.sorted { $0.frame.origin.x < $1.frame.origin.x }
        //            print("  Row \(index) [y:\(sortedRow.first?.frame.origin.y ?? -999)]: Items \(sortedRow.map { $0.indexPath.item }) Frames: \(sortedRow.map { $0.frame })")
        //        }
        // --- DEBUG END ---
        
        // Sadece birden fazla satır varsa ve son satır eksikse ortalama yap.
        guard rows.count > 1, let lastRowAttributes = rows.last, let firstRowAttributes = rows.first else {
            print("Skipping centering logic (rows=\(rows.count))")
            // --- DEBUG START ---
            //            print("Returning attributes without centering:")
            //            for attr in attributes where attr.representedElementCategory == .cell {
            //                print("  Final Attr [\(attr.indexPath.item)]: \(attr.frame)")
            //            }
            // --- DEBUG END ---
            return attributes // Return original attributes if only one row or error
        }
        
        // Check if last row is actually incomplete compared to the first row (more robust)
        if lastRowAttributes.count >= firstRowAttributes.count {
            //            print("Skipping centering logic (last row count >= first row count)")
            // --- DEBUG START ---
            //            print("Returning attributes without centering:")
            //            for attr in attributes where attr.representedElementCategory == .cell {
            //                print("  Final Attr [\(attr.indexPath.item)]: \(attr.frame)")
            //            }
            // --- DEBUG END ---
            return attributes
        }
        
        print("Applying centering logic to last row (\(lastRowAttributes.map { $0.indexPath.item }))")
        
        // Son satırdaki öğe sayısı.
        let itemsInLastRow = lastRowAttributes.count
        
        let totalItemWidth = lastRowAttributes.reduce(0) { $0 + $1.frame.width }
        // .reduce -> 0 dan başla ve hepsinin toplamını $0 da tutarak hepsini ekle
        let totalSpacingWidth = minimumInteritemSpacing * CGFloat(itemsInLastRow - 1)
        let lastRowContentWidth = totalItemWidth + totalSpacingWidth
        
        // Ortalama için gereken sol boşluğu (inset) hesapla.
        let collectionViewWidth = collectionView?.bounds.width ?? 0
        let leftInset = (collectionViewWidth - lastRowContentWidth) / 2
        
        // Son satırdaki her öğenin X konumunu güncelle.
        var currentX = leftInset
        // Sort last row attributes by initial X position before applying new X
        let sortedLastRowAttributes = lastRowAttributes.sorted { $0.frame.origin.x < $1.frame.origin.x }
        for attribute in sortedLastRowAttributes {
            var frame = attribute.frame
            frame.origin.x = max(sectionInset.left, currentX) // Ensure we don't go left of section inset
            attribute.frame = frame
            currentX += frame.width + minimumInteritemSpacing
            //            print("  Adjusted Attr [\(attribute.indexPath.item)]: \(attribute.frame)")
        }
        
        // --- DEBUG START ---
        //        print("Returning attributes *with* centering:")
        //        for attr in attributes where attr.representedElementCategory == .cell {
        //            print("  Final Attr [\(attr.indexPath.item)]: \(attr.frame)")
        //        }
        // --- DEBUG END ---
        
        return attributes
    }
}
