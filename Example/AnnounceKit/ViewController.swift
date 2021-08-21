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

    @IBOutlet weak var announceKitView: AnnounceKitView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let settings = AnnounceKitSettings(text: "What's New", widget: "1yAi3u", userID: String(Date().timeIntervalSince1970))
        announceKitView.delegate = self
        announceKitView.settings = settings
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

    func announceKitView(_ view: AnnounceKitView, didInitialize widget: String) {

    }

    func announceKitView(_ view: AnnounceKitView, didOpenWidget widget: String) {

    }

    func announceKitView(_ view: AnnounceKitView, didCloseWidget widget: String) {

    }

    func announceKitView(_ view: AnnounceKitView, didInitializeWidget widget: String) {

    }

    func announceKitView(_ view: AnnounceKitView, didUpdateUnreadCount count: Int, widget: String) {

    }
}
