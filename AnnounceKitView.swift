//
//  AKBadgeView.swift
//  AnnounceKit
//
//  Created by Seyfeddin Bassarac on 30.06.2021.
//

import UIKit
import WebKit

public struct AnnounceKitSettings {

    public var text: String?
    public var widget: String?
    public var userID: String?

    public init(text: String? = nil, widget: String? = nil, userID: String? = nil) {
        self.text = text
        self.widget = widget
        self.userID = userID
    }
}

open class AnnounceKitView: UIView {

    private var contentController = AKContentController()
    private var webView: WKWebView!

    private var isOpen: Bool = false

    var unreadCount: Int = 0

    private let messenger: AKMessenger

    public var settings: AnnounceKitSettings? {
        didSet {
            self.configure()
        }
    }

    public init(withSettings settings: AnnounceKitSettings) {
        self.settings = settings
        self.messenger = AKMessenger()

        super.init(frame: .zero)
        configureWebView()

        addSubview(webView)
        self.messenger.view = self
    }

    required public init?(coder: NSCoder) {

        self.messenger = AKMessenger()
        super.init(coder: coder)

        configureWebView()

        addSubview(webView)
        self.messenger.view = self
    }

    private func configureWebView() {

        let configuration = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        configuration.preferences.javaScriptEnabled = true
        configuration.userContentController = contentController
        configuration.userContentController.add(messenger, name: AKMessageType.eventTrigger)
        configuration.userContentController.add(messenger, name: AKMessageType.updateUnreadCount)
        configuration.userContentController.add(messenger, name: AKMessageType.logHandler)

        configuration.allowsInlineMediaPlayback = true
        self.webView = WKWebView(frame: .zero, configuration: configuration)
    }

    open override func layoutSubviews() {

        super.layoutSubviews()
        webView.frame = self.bounds
    }

    private func configure() {

        guard let scriptURL = Bundle(for: AnnounceKitView.self).url(forResource: "widget", withExtension: "html") else { return }

        self.webView.load(URLRequest(url: scriptURL))
    }

    private func createPushFunction(
        userId: String,
        widgetId: String,
        selector: String
    ) -> String {

        return """
                announcekit.push({
                    // Standard config
                    widget: "https://announcekit.app/widgets/v2/\(widgetId)",
                    selector: "\(selector)",
                    user: {
                        id: "\(userId)"
                    },
                    data: {
                        platform: "ios",
                        version: "\(1.0)"
                    }
                });
               """
    }

    public func displayContent() {

        let showContentScript = createPushFunction(userId: settings?.userID ?? "", widgetId: settings?.widget ?? "", selector: ".announcekit-widget")
        self.webView.evaluateJavaScript(showContentScript)
    }
}

private enum AKMessageType {

    static let updateUnreadCount = "updateUnreadCount"
    static let logHandler = "logHandler"
    static let errorHandler = "errorHandler"
    static let eventTrigger = "eventTrigger"
}

private class AKMessenger: NSObject, WKScriptMessageHandlerWithReply, WKScriptMessageHandler {

    weak var view: AnnounceKitView?

    override init() {
        super.init()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {

        switch message.name {
        case AKMessageType.updateUnreadCount:
            guard let dict = message.body as? [String: Any],
                  let unread = dict["unread"] as? Int,
                  let view = view else {
                return
            }

            view.unreadCount = unread
        case AKMessageType.logHandler:
            print(message.name)
            print("\(message.body)")
        case AKMessageType.eventTrigger:
            guard let dict = message.body as? [String: Any] else {
                print("error parsing event payload: \(message.name)")
                return
            }
        case AKMessageType.errorHandler:
            print("\(message.body)")
        default:
            print("error – unknown \(message.name)")
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage,
        replyHandler: @escaping (Any?, String?) -> Void
    ) {

        print(message.name)
        print(message.body)
    }
}

private class AKContentController: WKUserContentController {}
