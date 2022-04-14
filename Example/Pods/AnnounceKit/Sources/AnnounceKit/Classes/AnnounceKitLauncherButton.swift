//
//  AnnounceKitLauncherButton.swift
//  AnnounceKit
//
//  Created by Seyfeddin Bassarac on 15.09.2021.
//

import UIKit

public struct AnnounceKitLauncherButtonSettings {

    public var title: String?
    public var unreadCount: Int = 0
    public var titleFont: UIFont?
    public var badgeTitleFont: UIFont = .systemFont(ofSize: 12.0)
    public var badgeBackgroundColor: UIColor = .systemRed
    public var titleColor: UIColor?
    public var badgeTitleColor: UIColor?
    public var badgeVerticalOffset: CGFloat = -2.0
    public var badgeHorizontalOffset: CGFloat = 2.0

    public init(
        title: String? = nil,
        titleFont: UIFont? = nil,
        badgeTitleFont: UIFont = .systemFont(ofSize: 12.0),
        badgeBackgroundColor: UIColor = .systemRed,
        titleColor: UIColor? = nil,
        badgeTitleColor: UIColor? = nil
    ) {

        self.title = title
        self.titleFont = titleFont
        self.badgeTitleFont = badgeTitleFont
        self.badgeBackgroundColor = badgeBackgroundColor
        self.titleColor = titleColor
        self.badgeTitleColor = badgeTitleColor
    }
}

open class AnnounceKitLauncherButton: UIButton {

    internal var badgeButton: UIButton?

    public var buttonSettings: AnnounceKitLauncherButtonSettings? {
        didSet {
            commonInit()
        }
    }

    private var hasTitle: Bool {

        guard let title = buttonSettings?.title else { return false }

        return !title.isEmpty
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        if let settings = buttonSettings {
            if !hasTitle {
                backgroundColor = settings.badgeBackgroundColor
                setTitleColor(settings.badgeTitleColor ?? .white, for: .normal)
                setTitle(String(settings.unreadCount), for: .normal)
                titleLabel?.font = settings.badgeTitleFont
                layer.cornerRadius = bounds.height / 2.0
                contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
            } else {
                clipsToBounds = false
                if badgeButton == nil {
                    let badge = UIButton(type: .custom)
                    addSubview(badge)
                    badgeButton = badge
                }
                badgeButton?.setTitle(String(settings.unreadCount), for: .normal)
                badgeButton?.backgroundColor = settings.badgeBackgroundColor
                badgeButton?.setTitleColor(settings.badgeTitleColor, for: .normal)
                badgeButton?.titleLabel?.font = settings.badgeTitleFont
                badgeButton?.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
                var defaultLabelColor: UIColor
                if #available(iOS 12.0, *) {
                    defaultLabelColor = traitCollection.userInterfaceStyle == .light ? .black : .white
                } else {
                    defaultLabelColor = .black
                }
                setTitleColor(
                    settings.titleColor ?? defaultLabelColor,
                    for: .normal
                )
                titleLabel?.font = settings.titleFont ?? .systemFont(ofSize: 18.0)
                backgroundColor = .clear
                layer.cornerRadius = .zero
                setTitle(settings.title, for: .normal)
                contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
                setNeedsDisplay()
                badgeButton?.sizeToFit()
                if let badgeButton = badgeButton {
                    badgeButton.frame = CGRect(
                        x: bounds.width,
                        y: 0,
                        width: badgeButton.bounds.width < badgeButton.bounds.height ? badgeButton.bounds.height : badgeButton.bounds.width,
                        height: badgeButton.bounds.height
                    )
                }
            }
        } else {
            backgroundColor = .systemRed
            titleLabel?.font = .systemFont(ofSize: 12.0)
            setTitleColor(.white, for: .normal)
            setTitle("", for: .normal)
            layer.cornerRadius = bounds.height / 2.0
            contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        }
    }

    open override func layoutSubviews() {

        super.layoutSubviews()

        if let badgeButton = badgeButton {
            badgeButton.sizeToFit()
            badgeButton.frame = CGRect(
                x: bounds.width - (badgeButton.bounds.width / 2) + (buttonSettings?.badgeHorizontalOffset ?? 0.0),
                y: 0 + (buttonSettings?.badgeVerticalOffset ?? 0.0),
                width: badgeButton.bounds.width < badgeButton.bounds.height ? badgeButton.bounds.height : badgeButton.bounds.width,
                height: badgeButton.bounds.height
            )
            badgeButton.layer.cornerRadius = badgeButton.bounds.height / 2.0
        }
    }
}
