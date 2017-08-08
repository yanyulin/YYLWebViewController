//
//  YYLWebViewController.m
//  YYLWebViewController
//
//  Created by yyl on 2017/7/19.
//  Copyright © 2017年 yanyulin. All rights reserved.
//

#import "YYLWebViewController.h"
#import "YYLWeakScriptMessageDelegate.h"
#import <WebKit/WebKit.h>

typedef enum : NSUInteger {
    YYLWebViewLoadTypeURLString, //请求 url 地址
    YYLWebViewLoadTypeHTMLString,//请求本地 html
    YYLWebViewLoadTypeErrorString//请求错误提示页面
} YYLWebViewLoadType;

static void *WkwebBrowserContext = &WkwebBrowserContext;

static NSString * const kWebLoadErrorViewClick = @"kWebLoadErrorViewClick";


@interface YYLWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,UINavigationBarDelegate>

//加载进度条
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) WKWebView *wkwebView;

//加载内容类型
@property (nonatomic, assign) YYLWebViewLoadType webViewLoadType;

//保存的网址链接
@property (nonatomic, strong) NSString *urlString;

//返回按钮
@property (nonatomic, strong) UIBarButtonItem *customerBackBarItem;

//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeButtonBarItem;

//保存请求连接
@property (nonatomic, strong) NSMutableArray *snapShotsArrayM;

@end

@implementation YYLWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //加载网页类型
    [self loadURLType];
    //添加 webview
    [self.view addSubview:self.wkwebView];
    //添加进度条
    [self.view addSubview:self.progressView];
    
    //添加右边刷新按钮
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(leftBarbuttonItemClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self.navigationController;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.wkwebView.configuration.userContentController removeScriptMessageHandlerForName:kWebLoadErrorViewClick];
    [self.wkwebView setNavigationDelegate:nil];
    [self.wkwebView setUIDelegate:nil];
    [self.wkwebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

#pragma mark - private methods
- (void)loadURLType {
    switch (self.webViewLoadType) {
        case YYLWebViewLoadTypeURLString: {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
            [self.wkwebView loadRequest:request];
        }
            break;
        case YYLWebViewLoadTypeHTMLString: {
            [self loadWebWithURLString:self.urlString];
        }
            break;
        case YYLWebViewLoadTypeErrorString: {
            [self loadHostPathURL:@"YYLWebViewController.bundle/YYLWebLoadErrorView"];
        }
            
        default:
            break;
    }
}


/**
 加载本地 html 文件

 @param url url description
 */
- (void)loadHostPathURL:(NSString *)url {
    //获取 html 文件的路径
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:url ofType:@"html"];
    //获取 html 内容
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //加载 html
    [self.wkwebView loadHTMLString:html baseURL:[[NSBundle bundleForClass:self.class] bundleURL]];
}

- (void)loadWebWithURLString:(NSString *)urlString {
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.urlString = urlString;
    if (urlString.length > 0 && [urlString hasPrefix:@"http"]) {
        self.webViewLoadType = YYLWebViewLoadTypeURLString;
    } else {
        self.webViewLoadType = YYLWebViewLoadTypeErrorString;
    }
}

- (void)loadWebWithHTMLString:(NSString *)htmlString {
    self.urlString = htmlString;
    self.webViewLoadType = YYLWebViewLoadTypeHTMLString;
}

/**
 刷新导航栏左边 BarButtonItem
 */
- (void)loadNavigationItems {
    if (self.wkwebView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, self.customerBackBarItem, self.closeButtonBarItem] animated:NO];
    } else {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.customerBackBarItem]];
    }
}


/**
 请求连接处理

 @param request request description
 */
- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest *)request {
    NSURLRequest *lastRequest = (NSURLRequest *)[[self.snapShotsArrayM lastObject] objectForKey:@"request"];
    //如果不是正常的 url 就不 push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return;
    }
    //如果 url 一样就不 push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    UIView *currentSnapShotView = [self.wkwebView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArrayM addObject:@{@"request": request, @"snapShotView":currentSnapShotView}];
    
}


#pragma mark - Event
- (void)leftBarbuttonItemClick:(UIBarButtonItem *)barButtonItem {
    
}

- (void)customerBackBarItemClick:(UIButton *)button {
    if (self.wkwebView.goBack) {
        [self.wkwebView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeBarItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //开始加载的时候调用
    self.progressView.hidden = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 网页内容全部加载完成时调用
    self.title = self.wkwebView.title;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self loadNavigationItems];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //服务器开始请求的时候调用
    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated:
        case WKNavigationTypeFormSubmitted:
        case WKNavigationTypeOther:
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        case WKNavigationTypeBackForward:
        case WKNavigationTypeReload:
        case WKNavigationTypeFormResubmitted:
            break;
        default:
            break;
    }
    [self loadNavigationItems];
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.webViewLoadType = YYLWebViewLoadTypeErrorString;
    [self loadURLType];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //拦截执行 js 中的网页方法
    if ([message.name isEqualToString:kWebLoadErrorViewClick]) {
        //请求出错重试
        self.webViewLoadType = YYLWebViewLoadTypeErrorString;
        [self loadURLType];
    }
}
 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkwebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkwebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkwebView.estimatedProgress animated:animated];
        if (self.wkwebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - getter and setter methods
- (WKWebView *)wkwebView {
    if (!_wkwebView) {
        //设置网页的配置文件
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        //允许可以与网页交付， 选择视图
        configuration.selectionGranularity = YES;
        //web内容处理池
        configuration.processPool = [[WKProcessPool alloc] init];
        //是否支持记忆读取
        configuration.suppressesIncrementalRendering = NO;
        //自定义配置，一般用于 js 调用 oc 方法（OC 拦截 URL 中的数据做自定义操作）
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        //添加消息处理。 注意:self 指代的对象需要遵守 WKScriptMessageHandler 协议， 结束时需要移除
        [userContentController addScriptMessageHandler:[[YYLWeakScriptMessageDelegate alloc] initWithDelegate:self] name:kWebLoadErrorViewClick];
        //允许用户更改网页的设置
        configuration.userContentController = userContentController;
        _wkwebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        //_wkwebView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        //设置代理
        _wkwebView.navigationDelegate = self;
        _wkwebView.UIDelegate = self;
        //kvo 添加进度监听
        [_wkwebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WkwebBrowserContext];
        //开启手势触摸
        _wkwebView.allowsBackForwardNavigationGestures = YES;
        //适应指定的尺寸
        [_wkwebView sizeToFit];
        
    }
    return _wkwebView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 100)];
        [_progressView setTrackTintColor:[UIColor clearColor]];
        _progressView.progressTintColor = [UIColor greenColor];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
        _progressView.transform = transform;//设定宽高
    }
    return _progressView;
}

- (UIBarButtonItem *)customerBackBarItem {
    if (!_customerBackBarItem) { 
        UIButton *backButton = [[UIButton alloc] init];
        
        
        [backButton setImage:[UIImage imageNamed:@"YYLWebViewController.bundle/yylwebviewcontroller_nav_back" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"YYLWebViewController.bundle/yylwebviewcontroller_nav_back" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        [backButton addTarget:self action:@selector(customerBackBarItemClick:) forControlEvents:UIControlEventTouchUpInside];
        _customerBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customerBackBarItem;
}


- (UIBarButtonItem *)closeButtonBarItem {
    if (!_closeButtonBarItem) {
        _closeButtonBarItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeBarItemClick)];
    }
    return _closeButtonBarItem;
}

- (NSMutableArray *)snapShotsArrayM {
    if (!_snapShotsArrayM) {
        _snapShotsArrayM = [NSMutableArray array];
    }
    return _snapShotsArrayM;
}


@end
