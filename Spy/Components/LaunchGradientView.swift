//
//  GradientView.swift
//  Spy
//
//  Created by Zeynep Müslim on 3.07.2025.
//

import UIKit


@IBDesignable
class LaunchGradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
    }
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
}
