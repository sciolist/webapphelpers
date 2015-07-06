WKWebView+HideInputAccessoryView
================================

Simple port of a similar function for UIWebView, call a function and the input/form accessory view disappears. Good riddance!

Usage
-----

If you're using Swift, you'll have to [create an objective-c bridging header,](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) and make sure WKWebView+HideInputAccessoryView.h is #include'd.

To toggle the input accessory view, call setAccessoryViewEnabled(false)

    func doStuff(webview: WKWebView) {
		webview.setAccessoryViewEnabled(false)
	}




