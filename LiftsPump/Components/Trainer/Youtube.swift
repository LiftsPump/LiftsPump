//
//  Youtube.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 9/14/25.
//

import Foundation
import SwiftUI
import WebKit

func extractYouTubeID(from urlString: String) -> String? {
    // Covers youtu.be/VIDEOID, youtube.com/watch?v=VIDEOID, youtube.com/embed/VIDEOID
    guard let url = URL(string: urlString), let host = url.host else { return nil }
    if host.contains("youtu.be") {
        return url.lastPathComponent
    }
    if host.contains("youtube.com") {
        if url.path.contains("/embed/") {
            return url.pathComponents.last
        }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "v" })?.value
    }
    return nil
}

struct YouTubeView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <html><head><meta name=\"viewport\" content=\"initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width\"></head>
        <body style=\"margin:0;background-color:transparent;\">
        <iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/\(videoID)?playsinline=1&modestbranding=1&rel=0&controls=1&origin=https%3A%2F%2Fliftspump.com\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen referrerpolicy=\"origin\"></iframe>
        </body></html>
        """
        uiView.loadHTMLString(html, baseURL: URL(string: "https://liftspump.com"))
    }
}
