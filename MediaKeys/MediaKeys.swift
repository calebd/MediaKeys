//
//  MediaKeys.swift
//  MediaKeys
//
//  Created by Caleb Davenport on 5/6/15.
//  Copyright (c) 2015 Caleb Davenport. All rights reserved.
//

import AppKit

private func noop() {}

public enum MediaKey {
    case PlayPause
    case Rewind
    case Forward
}

public typealias MediaKeyObserver = (mediaKey: MediaKey) -> Void

public class MediaKeys: NSObject {

    // MARK: - Properties

    private var currentKeyTap: SPMediaKeyTap?

    private var currentObserver: MediaKeyObserver?


    // MARK: - NSObject

    public override class func initialize() {
        NSUserDefaults.standardUserDefaults().registerDefaults([kMediaKeyUsingBundleIdentifiersDefaultsKey: SPMediaKeyTap.defaultMediaKeyUserBundleIdentifiers()])
    }

    // MARK: - Public

    public func watch(observer: MediaKeyObserver) {
        currentKeyTap = SPMediaKeyTap(delegate: self)

        if SPMediaKeyTap.usesGlobalMediaKeyTap() {
            currentKeyTap?.startWatchingMediaKeys()
        }

        currentObserver = observer
    }


    // MARK: - SPMediaKeyTapDelegate

    public override func mediaKeyTap(keyTap: SPMediaKeyTap!, receivedMediaKeyEvent event: NSEvent!) {
        let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
        let keyFlags = (event.data1 & 0x0000FFFF)
        let keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA
        let keyRepeat = (keyFlags & 0x1)

        if keyIsPressed {
            switch Int32(keyCode) {
            case NX_KEYTYPE_PLAY:
                currentObserver?(mediaKey: .PlayPause)
            case NX_KEYTYPE_FAST:
                currentObserver?(mediaKey:.Forward)
            case NX_KEYTYPE_REWIND:
                currentObserver?(mediaKey:.Rewind)
            default:
                noop()
            }
        }
    }
}
