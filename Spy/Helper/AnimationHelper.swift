//
//  AnimationHelper.swift
//  Spy
//
//  Created by Zeynep Müslim on 5.03.2025.
//


import UIKit

public class AnimationHelper {
    
    public static func animateButton(
        firstView: UIView,
        thirdView: UIView,
        firstViewTopConstraint: NSLayoutConstraint,
        firstViewBottomConstraint: NSLayoutConstraint,
        firstViewLeadingConstraint: NSLayoutConstraint,
        firstViewTrailingConstraint: NSLayoutConstraint,
        outerCornerRadius: CGFloat,
        innerCornerRadius: CGFloat,
        borderWidth: CGFloat
    ) {
        UIView.animate(withDuration: GeneralConstants.Animation.duration, animations: {
            firstViewTopConstraint.constant = 0
            firstViewBottomConstraint.constant = 0
            firstViewLeadingConstraint.constant = 0
            firstViewTrailingConstraint.constant = 0
            firstView.layer.cornerRadius = outerCornerRadius
            thirdView.layer.shadowOpacity = 0
            firstView.superview?.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: GeneralConstants.Animation.duration) {
                firstView.transform = .identity
                firstViewTopConstraint.constant = borderWidth
                firstViewBottomConstraint.constant = -borderWidth
                firstViewLeadingConstraint.constant = borderWidth
                firstViewTrailingConstraint.constant = -borderWidth
                firstView.layer.cornerRadius = innerCornerRadius
                thirdView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
                firstView.superview?.layoutIfNeeded()
            }
        }
    }
}
