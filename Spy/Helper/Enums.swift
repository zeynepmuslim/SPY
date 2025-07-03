//
//  Enums.swift
//  Spy
//
//  Created by Zeynep Müslim on 1.04.2025.
//

import UIKit
 
enum ShadowColor {
      case red
      case blue
      case gray
      
      var cgColor: CGColor {
          switch self {
          case .red:
              return UIColor.spyRed01.cgColor
          case .blue:
              return UIColor.spyBlue01.cgColor
          case .gray:
              return UIColor.spyGray01.cgColor
          }
      }
  }

enum ButtonColor {
      case red
      case blue
      case gray
      
    var color: UIColor {
          switch self {
          case .red:
              return UIColor.spyRed03
          case .blue:
              return UIColor.spyBlue04
          case .gray:
              return UIColor.spyGray05
          }
      }
  }

enum ButtonStatus {
    case activeRed
    case activeBlue
    case deactive
    
    var shadowColor: ShadowColor {
        switch self {
        case .activeRed:
            return .red
        case .activeBlue:
            return .blue
        case .deactive:
            return .gray
        }
    }
    
    var gradientColor: GradientColor {
        switch self {
        case .activeRed:
            return .red
        case .activeBlue:
            return .blue
        case .deactive:
            return .gray
        }
    }
    
    var buttonColor: ButtonColor {
        switch self {
        case .activeRed:
            return .red
        case .activeBlue:
            return .blue
        case .deactive:
            return .gray
        }
    }
}

enum GradientColor {
    case blue
    case red
    case gray
    
    var colors: [CGColor] {
        switch self {
        case .blue:
            return [UIColor.spyBlue01G.cgColor, UIColor.spyBlue02G.cgColor]
        case .red:
            return [UIColor.spyRed01G.cgColor, UIColor.spyRed02G.cgColor]
        case .gray:
            return [UIColor.spyGray01G.cgColor, UIColor.spyGray02G.cgColor]
        }
    }
}

enum WinnerType: String, CaseIterable {
    case civilians = "CIVILIANS"
    case spies = "SPIES"
    case timeout = "TIMEOUT"
}

enum AppLanguage: String {
    case english = "en"
    case turkish = "tr"
    
    static var current: AppLanguage {
        let locale = Locale.current.languageCode ?? "en"
        return AppLanguage(rawValue: locale) ?? .english
    }
}

