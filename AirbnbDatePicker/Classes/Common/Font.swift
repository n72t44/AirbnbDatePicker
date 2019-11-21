//
//  Font.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/10.
//

import Foundation

enum Font {
    static func regular(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func medium(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func bold(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static var smallSize : CGFloat {
        get {
            return ThemeManager.current.modal ? 17 : 14
        }
    }
    static var mediumSize : CGFloat {
        get {
            return ThemeManager.current.modal ? 20 : 16
        }
    }
}
