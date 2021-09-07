//
//  BadgeOnlyViewController.swift
//  AnnounceKit_Example
//
//  Created by Seyfeddin Bassarac on 7.09.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AnnounceKit

class BadgeOnlyViewController: UIViewController {

    private var announceKitClient: AnnounceKitClient!
    private var launcherButton: AnnounceKitLauncherButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = AnnounceKitSettings(widget: "3tNOGA")
        announceKitClient = AnnounceKitClient(withSettings: settings, viewControllerToPresent: self)
        announceKitClient.delegate = self

        announceKitClient.prepareLauncher(
            launcherSettings: AnnounceKitLauncherButtonSettings(
                badgeBackgroundColor: .systemBlue
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

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.announceKitClient.displayContent()
        })
    }
}

// MARK: - AnnounceKitDelegate

extension BadgeOnlyViewController: AnnounceKitDelegate {

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
