//
//  YYLWebViewController.h
//  YYLWebViewController
//
//  Created by yyl on 2017/7/19.
//  Copyright © 2017年 yanyulin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYLWebViewController : UIViewController


/**
 是否影藏导航栏
 */
@property (nonatomic,assign) BOOL isHiddenNav;


/**
 加载指定 url地址网页

 @param urlString url 地址
 */
- (void)loadWebWithURLString:(NSString *)urlString;



/**
 加载本地 html 字符串

 @param htmlString 本地 html 内容
 */
- (void)loadWebWithHTMLString:(NSString *)htmlString;

@end
