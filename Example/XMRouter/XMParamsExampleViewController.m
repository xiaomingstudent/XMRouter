//
//  XMParamsExampleViewController.m
//  XMRouter_Example
//
//  Created by 李明 on 2021/2/18.
//  Copyright © 2021 402187526@qq.com. All rights reserved.
//

#import "XMParamsExampleViewController.h"
#import <XMRouterDelegate.h>

@interface XMParamsExampleViewController ()<XMRouterDelegate>

@end

@implementation XMParamsExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

//+ (NSString *)routerKey {
//    return @"paramsExampleVC";
//}

+ (NSDictionary *)ReplacedKeyFromPropertyName {
    return @{@"name":@"aName"};
}

+ (BOOL)shouldCustomTransform:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"date"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"peoples"]) {
        return YES;
    }
    return NO;
}

+ (id)customParam:(id)param toPropertyValueWithPropertyName:(NSString *)propertyName {
    
    if ([propertyName isEqualToString:@"date"]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[param doubleValue]];
        return date;
    }
    if ([propertyName isEqualToString:@"peoples"]) {
        return @[param];
    }
    return nil;
}



@end
