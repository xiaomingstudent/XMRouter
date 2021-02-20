//
//  XMPresentViewController.m
//  XMRouter_Example
//
//  Created by 李明 on 2021/2/1.
//  Copyright © 2021 402187526@qq.com. All rights reserved.
//

#import "XMPresentViewController.h"
#import <XMRouterDelegate.h>

@interface XMPresentViewController ()<XMRouterDelegate>

@end

@implementation XMPresentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}

//+ (NSString *)routerKey {
//    return @"presentVC";
//}



@end
