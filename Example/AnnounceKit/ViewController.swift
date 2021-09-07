//
//  ViewController.swift
//  AnnounceKit
//
//  Created by Seyfeddin Başsaraç on 06/20/2021.
//  Copyright (c) 2021 Seyfeddin Başsaraç. All rights reserved.
//

import UIKit
import AnnounceKit

class ViewController: UIViewController {

    var announceKitView: AnnounceKitClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let settings = AnnounceKitSettings(widget: "3tNOGA")
        announceKitView = AnnounceKitClient(withSettings: settings, viewControllerToPresent: self)
        announceKitView.delegate = self
        announceKitView.prepareLauncher(
            launcherSettings: AnnounceKitLauncherButtonSettings(
                title: "What's New"
            )
        ) { (button) in
            self.view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalTo: button.heightAnchor),
                button.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
        }
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.announceKitView.displayContent()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: AnnounceKitDelegate {

    func announceKitView(_ client: AnnounceKitClient, didInitialize widget: String) {

    }

    func announceKitView(_ client: AnnounceKitClient, didOpenWidget widget: String) {}

    func announceKitView(_ client: AnnounceKitClient, didCloseWidget widget: String) {}

    func announceKitView(_ client: AnnounceKitClient, didInitializeWidget widget: String) {

    }

    func announceKitView(_ client: AnnounceKitClient, didUpdateUnreadCount count: Int, widget: String) {

    }
}
