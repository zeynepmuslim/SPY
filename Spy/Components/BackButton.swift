//
//  BackButton.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.03.2025.
//

import UIKit

class BackButton: UIButton {
    
    init(target: Any?, action: Selector) {
        super.init(frame: .zero)
        
        let backImage = UIImage(systemName: "chevron.left")
        self.setImage(backImage, for: .normal)
        self.tintColor = .spyBlue01
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
