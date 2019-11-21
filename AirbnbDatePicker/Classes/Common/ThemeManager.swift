//
//  ThemeManager.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/30.
//

import UIKit

public struct ThemeManager {
    public var mainColor = UIColor(hexString: "#4F86C6")
    public var textColor = UIColor(hexString: "#484848")
    public var disabledColor = UIColor(hexString: "#d4d4d4")
    public var separatorColor = UIColor(hexString: "#ebebeb")
    public var placeholderColor = UIColor(hexString: "#888888")
    public var buttonColor = UIColor(hexString: "#0000FF")
    public var modal = false
    public var circleCurrent = true
    public var headFootColor : UIColor?

    public init() {}
}

public extension ThemeManager {
    static let `default` = ThemeManager()
    static var current: ThemeManager = .default
}
