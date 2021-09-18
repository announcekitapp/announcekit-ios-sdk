//
//  CustomButtonViewController.swift
//  AnnounceKit_Example
//
//  Created by Seyfeddin Bassarac on 18.09.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AnnounceKit

class CustomButtonViewController: UIViewController {

    private var announceKitClient: AnnounceKitClient!
    @IBOutlet private weak var customButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = AnnounceKitSettings(widget: "3xdhio")
        announceKitClient = AnnounceKitClient(withSettings: settings, viewControllerToPresent: self)
        announceKitClient.delegate = self
        customButton.isEnabled = false
        announceKitClient.startWidget()
    }

    @IBAction private func customButtonTapped(_ sender: UIButton) {

        announceKitClient.presentWidget()
    }
}

// MARK: - AnnounceKitDelegate

extension CustomButtonViewController: AnnounceKitDelegate {

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
    ) {

        customButton.isEnabled = true
    }

    func announceKitView(
        _ client: AnnounceKitClient,
        didUpdateUnreadCount count: Int,
        widget: String
    ) {}
}
