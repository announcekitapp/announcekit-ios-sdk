//
//  BadgeWithTextViewController.swift
//  AnnounceKit_Example
//
//  Created by Seyfeddin Bassarac on 7.09.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AnnounceKit

class BadgeWithTextViewController: UIViewController {

    private var announceKitClient: AnnounceKitClient!
    private var launcherButton: AnnounceKitLauncherButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = AnnounceKitSettings(widget: "2nI0Ok", language: "fr")
        announceKitClient = AnnounceKitClient(withSettings: settings, viewControllerToPresent: self)
        announceKitClient.delegate = self

        announceKitClient.prepareLauncher(
            launcherSettings: AnnounceKitLauncherButtonSettings(
                title: "What's New"
            )
        ) { (button) in
            self.view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
            ])
            self.launcherButton = button
        }
    }
}

// MARK: - AnnounceKitDelegate

extension BadgeWithTextViewController: AnnounceKitDelegate {

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

        launcherButton?.buttonSettings?.unreadCount = count
    }
}
