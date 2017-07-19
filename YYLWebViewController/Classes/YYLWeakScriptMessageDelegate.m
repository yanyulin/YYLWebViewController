//
//  YYLWeakScriptMessageDelegate.m
//  YYLWebViewController
//
//  Created by yyl on 2017/7/19.
//  Copyright © 2017年 yanyulin. All rights reserved.
//

#import "YYLWeakScriptMessageDelegate.h"

@implementation YYLWeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    if (self = [super init]) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
