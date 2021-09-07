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

public struct AnnounceKitLauncherButtonSettings {

    var title: String?
    var unreadCount: Int = 0
    var titleFont: UIFont?
    var badgeTitleFont: UIFont = .systemFont(ofSize: 12.0)
    var badgeBackgroundColor: UIColor?
    var titleColor: UIColor?
    var badgeTitleColor: UIColor?

    public init(
        title: String? = nil,
        titleFont: UIFont? = nil,
        badgeTitleFont: UIFont = .systemFont(ofSize: 12.0),
        badgeBackgroundColor: UIColor? = nil,
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

    private var badgeButton: UIButton?

    var buttonSettings: AnnounceKitLauncherButtonSettings? {
        didSet {
            commonInit()
            setNeedsDisplay()
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
                backgroundColor = settings.badgeBackgroundColor ?? .systemRed
                setTitleColor(settings.badgeTitleColor ?? .white, for: .normal)
                setTitle(settings.unreadCount > 0 ? String(settings.unreadCount) : " ", for: .normal)
                titleLabel?.font = settings.badgeTitleFont
                layer.cornerRadius = bounds.height / 2.0
                contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
            } else {
                badgeButton = UIButton(type: .custom)
                badgeButton?.setTitle(String(settings.unreadCount), for: .normal)
                badgeButton?.backgroundColor = settings.badgeBackgroundColor
                badgeButton?.setTitleColor(settings.badgeTitleColor, for: .normal)
                badgeButton?.titleLabel?.font = settings.badgeTitleFont
                if let badgeButton = badgeButton {
                    addSubview(badgeButton)
                    badgeButton.sizeToFit()
                    NSLayoutConstraint.activate([
                        badgeButton.centerXAnchor.constraint(equalTo: trailingAnchor),
                        badgeButton.centerYAnchor.constraint(equalTo: topAnchor)
                    ])
                }
                setTitleColor(settings.titleColor ?? .black, for: .normal)
                titleLabel?.font = settings.titleFont ?? .systemFont(ofSize: 18.0)
                backgroundColor = .clear
                layer.cornerRadius = .zero
                setTitle(settings.title, for: .normal)
                contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
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

        if layer.cornerRadius != bounds.height / 2.0 {
            layer.cornerRadius = bounds.height / 2.0
        }
    }
}

open class AnnounceKitView: UIView {

    private var contentController = AKContentController()
    private var webView: WKWebView!

    private var isOpen: Bool = false

    var unreadCount: Int = 0

    fileprivate var launcherCompletion: ((UIButton) -> ())?
    fileprivate var launcherSettings: AnnounceKitLauncherButtonSettings?

    public weak var viewControllerToPresent: UIViewController?

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

    public init(withSettings settings: AnnounceKitSettings, viewControllerToPresent: UIViewController? = nil) {
        self.settings = settings
        self.viewControllerToPresent = viewControllerToPresent
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

    public func prepareLauncher(
        launcherSettings: AnnounceKitLauncherButtonSettings?,
        completion: @escaping (UIButton) -> ()
    ) {

        launcherCompletion = completion
        self.launcherSettings = launcherSettings
        configure()
        displayContent()
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

    @objc fileprivate func buttonTapped(_ sender: UIButton) {

        let wkWebViewController = UIViewController()
        if let webView = self.webView {
            self.webView.removeFromSuperview()
            self.webView = webView
            wkWebViewController.view.addSubview(self.webView)
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 11.0, *) {
                NSLayoutConstraint.activate([
                    self.webView.topAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.topAnchor),
                    self.webView.bottomAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.bottomAnchor),
                    self.webView.leadingAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.leadingAnchor),
                    self.webView.trailingAnchor.constraint(equalTo: wkWebViewController.view.safeAreaLayoutGuide.trailingAnchor),
                ])
            } else {
                NSLayoutConstraint.activate([
                    self.webView.topAnchor.constraint(equalTo: wkWebViewController.topLayoutGuide.bottomAnchor),
                    self.webView.bottomAnchor.constraint(equalTo: wkWebViewController.bottomLayoutGuide.topAnchor),
                    self.webView.leadingAnchor.constraint(equalTo: wkWebViewController.view.leadingAnchor),
                    self.webView.trailingAnchor.constraint(equalTo: wkWebViewController.view.trailingAnchor),
                ])
            }
        }

        if #available(iOS 13.0, *) {
            wkWebViewController.isModalInPresentation = true
        }

        wkWebViewController.modalPresentationStyle = .overFullScreen
        wkWebViewController.modalTransitionStyle = .crossDissolve

        self.webView.transform = CGAffineTransform(translationX: wkWebViewController.view.bounds.width, y: 0)

        viewControllerToPresent?.present(wkWebViewController, animated: true, completion: {
            UIView.animate(withDuration: 0.3) {
                self.webView.evaluateJavaScript("announcekit.widgets[0].open()", completionHandler: nil)
                self.webView.transform = .identity
            }
        })
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

private class AKMessenger: NSObject, WKScriptMessageHandler {

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

            if view.launcherCompletion != nil {
                let button = AnnounceKitLauncherButton(frame: .zero)
                var launcherSettings = view.launcherSettings ?? AnnounceKitLauncherButtonSettings()
                launcherSettings.unreadCount = view.unreadCount
                button.buttonSettings = launcherSettings
                button.addTarget(view, action: #selector(AnnounceKitView.buttonTapped(_:)), for: .touchUpInside)
                view.launcherCompletion?(button)
                view.launcherCompletion = nil
            }
        case .widgetOpen:
            delegate?.announceKitView(view, didOpenWidget: widgetID)
        case .widgetClose:
            view.viewControllerToPresent?.dismiss(animated: true, completion: nil)
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
