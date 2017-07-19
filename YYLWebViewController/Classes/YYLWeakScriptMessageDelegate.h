//
//  YYLWeakScriptMessageDelegate.h
//  YYLWebViewController
//
//  Created by yyl on 2017/7/19.
//  Copyright © 2017年 yanyulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKScriptMessageHandler.h>

@interface YYLWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;


/**
 自定义代理 解决循环引用不释放的问题

 @param scriptDelegate scriptDelegate description
 @return return value description
 */
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
