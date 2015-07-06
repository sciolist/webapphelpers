import WebKit
import XWebView
import CoreLocation

class GeolocationApi : NSObject, XWVScripting, CLLocationManagerDelegate {
    var location: CLLocationManager
    var callback: XWVScriptObject?
    
    static func appendTo(webview: WKWebView) {
        webview.loadPlugin(GeolocationApi(), namespace: "navigator._geolocation")
    }
    
    override init() {
        self.location = CLLocationManager()
        super.init()
        
        self.location.delegate = self
        self.location.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start(callbackFunction: AnyObject?) {
        self.callback = callbackFunction as? XWVScriptObject
        self.location.requestWhenInUseAuthorization()
        self.location.startUpdatingLocation()
        
        if (!CLLocationManager.locationServicesEnabled()) {
            dispatch_async(dispatch_get_main_queue()) {
                callback?.call(arguments: [1])
            }
        }
    }
    
    func stop() {
        self.location.stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        dispatch_async(dispatch_get_main_queue()) {
            callback?.call(arguments: [2])
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var loc = locationArray.lastObject as? CLLocation
        if (loc == nil) { return; }
        
        var value = [
            round(loc!.timestamp!.timeIntervalSince1970 * 1000),
            loc!.coordinate.longitude,
            loc!.coordinate.latitude,
            loc!.altitude,
            loc!.horizontalAccuracy,
            loc!.course,
            loc!.speed
        ]
        
        dispatch_async(dispatch_get_main_queue()) {
            callback?.call(arguments: [0, value])
        }
    }
    
    func javascriptStub(stub: String) -> String {
        
        var geoPrefix = "(function() { var g = window.navigator.geolocation, gs = window.navigator._geolocation;\n"
        var geoSuffix = "\n})();\n"
        
        var geo1 = ([
            "gs.registered = {};"
            , "\n gs.uid = 0;"
            , "\n gs.makeError = function (c) { var ex = new Error(['', 'Permission denied', 'Position unavailable', 'Timeout'][c]); ex.code = Number(c); return ex; };"
            , "\n gs.callback = function (err, v) { console.log(err, v); "
            , "\n   if (v) v = JSON.parse(JSON.stringify({ coords: { longitude: v[1], latitude: v[2], altitude: v[3], accuracy: v[4], heading: v[5], speed: v[6] }, timestamp: v[0] }))"
            , "\n   if (err) { err = gs.makeError(err); }"
            , "\n   for(var key in gs.registered) {"
            , "\n     gs.registered[key].called = true;"
            , "\n     var cb = gs.registered[key][err ? 'err' : 'success']"
            , "\n     cb && cb(err || v);"
            , "\n   }"
            , "\n };"
            ].reduce("", combine: +))
        
        var geo2 = ([
            "g.getCurrentPosition = function(successCallback, errorCallback, opts) {"
            , "\n   var n = g.watchPosition(function (v) { g.clearWatch(n); successCallback && successCallback(v); successCallback = errorCallback = null; },"
            , "\n                           function (v) { g.clearWatch(n); errorCallback && errorCallback(v); successCallback = errorCallback = null; });"
            , "\n }; "
            ].reduce("", combine: +))
        
        var geo3 = ([
            "g.watchPosition = function(successCallback, errorCallback, opts) {"
            , "\n     var data = { err: errorCallback, success: successCallback, opts: opts };"
            , "\n     var id = (++gs.uid)"
            , "\n     gs.registered[id] = data;"
            , "\n     if (opts && opts.timeout) {"
            , "\n       setTimeout(function(){ if (!data.called) { g.clearWatch(id); errorCallback(gs.makeError(3)); }  }, opts.timeout * 1000);"
            , "\n     }"
            , "\n     gs.start(gs.callback);"
            , "\n     return id;"
            , "\n };"
            ].reduce("", combine: +))
        
        var geo4 = ([
            "g.clearWatch = function(id) {"
            , "\n   delete gs.registered[id];"
            , "\n   if (Object.keys(gs.registered).length === 0) { gs.stop(); }"
            , "\n };"
            ].reduce("", combine: +))
        
        return stub + geoPrefix + geo1 + geo2 + geo3 + geo4 + geoSuffix;
    }
}
