#import <objc/runtime.h>
#import "UIWebView+HideInputAccessoryView.h"

// http://stackoverflow.com/questions/19033292/ios-7-uiwebview-keyboard-issue/19042279#19042279
@implementation WKWebView (HideInputAccessoryView)

- (id)returnsNil {
    return nil;
}

- (void) setAccessoryViewEnabled:(BOOL)on {
    UIView* subview;
    for (UIView* view in self.scrollView.subviews) {
        if([[view.class description] hasPrefix:@"WKContentView"]) {
            subview = view;
            break;
        }
    }
    
    if(subview == nil) return;
    
    if (on)
    {
        object_setClass(subview, objc_getClass("WKContentView"));
    }
    else
    {
        NSString* name = [NSString stringWithFormat:@"%@WKContentView_HideAccessoryView", subview.class.superclass];
        Class newClass = NSClassFromString(name);
    
        if(newClass == nil)
        {
            newClass = objc_allocateClassPair(subview.class, [name cStringUsingEncoding:NSASCIIStringEncoding], 0);
            if(!newClass) return;
        
            Method method = class_getInstanceMethod([self class], @selector(returnsNil));
            class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));
        
            objc_registerClassPair(newClass);
        }
        
        object_setClass(subview, newClass);
    }
}

@end
