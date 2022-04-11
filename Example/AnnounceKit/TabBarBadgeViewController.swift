//
//  TabBarBadgeViewController.swift
//  AnnounceKit_Example
//
//  Created by Seyfeddin Bassarac on 18.09.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AnnounceKit

class TabBarBadgeViewController: UIViewController {

    private var announceKitClient: AnnounceKitClient!

    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = AnnounceKitSettings(widget: "2nI0Ok")
        announceKitClient = AnnounceKitClient(withSettings: settings, viewControllerToPresent: self)
        announceKitClient.delegate = self
        announceKitClient.startWidget()
    }
}

// MARK: - AnnounceKitDelegate

extension TabBarBadgeViewController: AnnounceKitDelegate {

    func announceKitView(
        _ client: AnnounceKitClient,
        didInitialize widget: String
    ) {}

    func announceKitView(
        _ client: AnnounceKitClient,
        didOpenWidget widget: String
    ) {}

    func announceKitView(
        _ client: AnnounceKitClient,
        didCloseWidget widget: String
    ) {}

    func announceKitView(
        _ client: AnnounceKitClient,
        didInitializeWidget widget: String
    ) {}

    func announceKitView(
        _ client: AnnounceKitClient,
        didUpdateUnreadCount count: Int,
        widget: String
    ) {

        tabBarItem.badgeValue = String(count)
        tabBarItem.badgeColor = .systemRed
    }
}
