//
//  XMConfig.m
//  XMRouter_Example
//
//  Created by 李明 on 2021/2/18.
//  Copyright © 2021 402187526@qq.com. All rights reserved.
//

#import "XMConfig.h"
#import "XMPresentViewController.h"
#import "XMParamsExampleViewController.h"

@implementation XMConfig

- (NSString *)appScheme {
    return @"xmrouter";
}

//全局注册，在这里注册之后 就不用实现routerkey方法
- (NSDictionary *)globlaRouters {
    return @{
        @"presentVC":@"XMPresentViewController",
        @"paramsExampleVC":[XMParamsExampleViewController class],
    };
}


- (void)dealRouteError:(NSError *)error {
    NSLog(@"%@",error);
}

//当路由地址是scheme为http时会调用这个方法 可以在这里用自己的webController打开地址
- (void)openHttpRoute:(NSString *)httpUrl {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:httpUrl]];
}

@end
