//
//  AKMessenger.swift
//  AnnounceKit
//
//  Created by Seyfeddin Bassarac on 15.09.2021.
//

import Foundation
import WebKit

enum AKMessageType {

    static let updateUnreadCount = "updateUnreadCount"
    static let logHandler = "logHandler"
    static let errorHandler = "errorHandler"
    static let eventTrigger = "eventTrigger"
}

enum AKEventName: String {

    case initialize = "init"
    case widgetInit = "widget-init"
    case widgetOpen = "widget-open"
    case widgetClose = "widget-close"
}

class AKMessenger: NSObject, WKScriptMessageHandler {

    weak var client: AnnounceKitClient?

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
                  let view = client else {
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
              let view = client else {
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
                button.badgeButton?.addTarget(view, action: #selector(AnnounceKitClient.buttonTapped(_:)), for: .touchUpInside)
                button.addTarget(view, action: #selector(AnnounceKitClient.buttonTapped(_:)), for: .touchUpInside)
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

class AKContentController: WKUserContentController {}
