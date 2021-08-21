//
//  AKBadgeView.swift
//  AnnounceKit
//
//  Created by Seyfeddin Bassarac on 30.06.2021.
//

import UIKit
import WebKit

public struct AnnounceKitSettings {

    public var widget: String
    public var userID: String?
    public var name: String?
    public var language: String?
    public var isBoostersEnabled: Bool = false
    public var user: [String: Any]?
    public var customFields: [String: Any]?

    public init(
        widget: String,
        userID: String? = nil,
        name: String? = nil,
        language: String? = nil,
        isBoostersEnabled: Bool = false,
        user: [String : Any]? = nil,
        customFields: [String : Any]? = nil
    ) {
        self.widget = widget
        self.userID = userID
        self.name = name
        self.language = language
        self.isBoostersEnabled = isBoostersEnabled
        self.user = user
        self.customFields = customFields
    }
}

public protocol AnnounceKitDelegate: AnyObject {

    func announceKitView(
        _ view: AnnounceKitView,
        didInitialize widget: String
    )
    func announceKitView(
        _ view: AnnounceKitView,
        didInitializeWidget widget: String
    )
    func announceKitView(
        _ view: AnnounceKitView,
        didOpenWidget widget: String
    )
    func announceKitView(
        _ view: AnnounceKitView,
        didCloseWidget widget: String
    )
    func announceKitView(
        _ view: AnnounceKitView,
        didUpdateUnreadCount count: Int,
        widget: String
    )
}

public extension AnnounceKitDelegate {

    func announceKitView(
        _ view: AnnounceKitView,
        didInitialize widget: String
    ) {}
    func announceKitView(
        _ view: AnnounceKitView,
        didInitializeWidget widget: String
    ) {}
    func announceKitView(
        _ view: AnnounceKitView,
        didOpenWidget widget: String
    ) {}
    func announceKitView(
        _ view: AnnounceKitView,
        didCloseWidget widget: String
    ) {}
    func announceKitView(
        _ view: AnnounceKitView,
        didUpdateUnreadCount count: Int,
        widget: String
    ) {}
}

open class AnnounceKitView: UIView {

    private var contentController = AKContentController()
    private var webView: WKWebView!

    private var isOpen: Bool = false

    var unreadCount: Int = 0

    public weak var delegate: AnnounceKitDelegate? {
        didSet {
            messenger.delegate = delegate
        }
    }

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
        self.messenger.delegate = delegate
    }

    required public init?(coder: NSCoder) {

        self.messenger = AKMessenger()
        super.init(coder: coder)

        configureWebView()

        addSubview(webView)
        self.messenger.view = self
        self.messenger.delegate = delegate
    }

    private func configureWebView() {

        let configuration = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        configuration.preferences.javaScriptEnabled = true
        contentController.add(messenger, name: AKMessageType.eventTrigger)
        contentController.add(messenger, name: AKMessageType.updateUnreadCount)
        contentController.add(messenger, name: AKMessageType.logHandler)
        configuration.userContentController = contentController

        configuration.allowsInlineMediaPlayback = true
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        configure()
    }

    open override func layoutSubviews() {

        super.layoutSubviews()
        webView.frame = self.bounds
    }

    private func configure() {

        guard let scriptURL = Bundle(for: AnnounceKitView.self).url(forResource: "widget", withExtension: "html") else { return }

        self.webView.load(URLRequest(url: scriptURL))
    }

    private func createPushFunction() -> String? {

        guard let settings = self.settings else {
            print("AnnounceKit settings is missing")
            return nil
        }

        var config: [String: Any] = [
            "widget": "https://announcekit.app/widgets/v2/\(settings.widget)",
            "selector": ".announcekit-widget"
        ]

        if let user = settings.user {
            config["user"] = user
        }

        if let customData = settings.customFields {
            config["data"] = customData
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: config, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Error creating json string")
                return nil
            }
            return """
                    announcekit.push(
                        \(jsonString)
                    );
                    """
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    public func displayContent() {

        if let showContentScript = createPushFunction() {
            self.webView.evaluateJavaScript(showContentScript)
        }
    }
}

private enum AKMessageType {

    static let updateUnreadCount = "updateUnreadCount"
    static let logHandler = "logHandler"
    static let errorHandler = "errorHandler"
    static let eventTrigger = "eventTrigger"
}

private enum AKEventName: String {

    case initialize = "init"
    case widgetInit = "widget-init"
    case widgetOpen = "widget-open"
    case widgetClose = "widget-close"
}

private class AKMessenger: NSObject, WKScriptMessageHandlerWithReply, WKScriptMessageHandler {

    weak var view: AnnounceKitView?

    weak var delegate: AnnounceKitDelegate?

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
            delegate?.announceKitView(view, didUpdateUnreadCount: unread, widget: view.settings?.widget ?? "")
        case AKMessageType.logHandler:
            print(message.name)
            print("\(message.body)")
        case AKMessageType.eventTrigger:
            guard let dict = message.body as? [String: Any] else {
                print("error parsing event payload: \(message.name)")
                return
            }
            handleEventTrigger(withInfo: dict)
        case AKMessageType.errorHandler:
            print("\(message.body)")
        default:
            print("error – unknown \(message.name)")
        }
    }

    private func handleEventTrigger(withInfo info: [String: Any]) {

        guard let eventName = info["event"] as? String,
              let event = AKEventName(rawValue: eventName),
              let widget = info["widget"] as? [String: Any],
              let widgetID = widget["widget"] as? String,
              let view = view else {
            print("event name is missing: \(info)")
            return
        }

        switch event {
        case .initialize:
            delegate?.announceKitView(view, didInitialize: widgetID)
        case .widgetInit:
            delegate?.announceKitView(view, didInitializeWidget: widgetID)
        case .widgetOpen:
            delegate?.announceKitView(view, didOpenWidget: widgetID)
        case .widgetClose:
            delegate?.announceKitView(view, didCloseWidget: widgetID)
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
