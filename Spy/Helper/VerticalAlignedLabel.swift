//
//  VerticalAlignedLabel.swift
//  Spy
//
//  Created by Zeynep Müslim on 30.03.2025.
//


import UIKit

class VerticalAlignedLabel: UILabel {
    enum VerticalAlignment {
        case top
        case middle
        case bottom
        case custom(CGFloat) // custom vertical offset
    }

    var verticalAlignment: VerticalAlignment = .middle {
        didSet { setNeedsDisplay() }
    }

    override func drawText(in rect: CGRect) {
        guard self.text != nil else {
            super.drawText(in: rect)
            return
        }

        let textSize = sizeThatFits(CGSize(width: rect.width, height: CGFloat.greatestFiniteMagnitude))
        var newRect = rect

        switch verticalAlignment {
        case .top:
            newRect.size.height = textSize.height

        case .bottom:
            newRect.origin.y += rect.size.height - textSize.height
            newRect.size.height = textSize.height

        case .custom(let offset):
            newRect.origin.y += offset

        case .middle:
            break
        }

        super.drawText(in: newRect)
    }
}
