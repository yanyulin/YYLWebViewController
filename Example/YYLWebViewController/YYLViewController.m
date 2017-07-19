//
//  YYLViewController.m
//  YYLWebViewController
//
//  Created by yanyulin on 07/19/2017.
//  Copyright (c) 2017 yanyulin. All rights reserved.
//

#import "YYLViewController.h"
#import "YYLWebViewController.h"

@interface YYLViewController ()

@end

@implementation YYLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonClick:(id)sender {
    YYLWebViewController *webViewControler = [[YYLWebViewController alloc] init];
    [webViewControler loadWebWithURLString:@"http://www.yanyulin.top"];
    [self.navigationController pushViewController:webViewControler animated:YES];
    
}
@end
