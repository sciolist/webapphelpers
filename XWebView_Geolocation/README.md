XWebView Geolocation
====================

A Swift XWebView plugin that makes Geolocation work a bit better!

Caution: this is super hacky and might explode your device.

Usage
-----

Add the plugin by invoking `GeoLocationApi.appendTo(webview: WebKitView)`

    func doStuff(webview: WkWebView) {
        GeoLocationApi.appendTo(webview)
	}

With any luck, navigator.geolocation should now be hacked into submission!

