//
//  XMExampleView.m
//  XMRouter_Example
//
//  Created by 李明 on 2021/2/19.
//  Copyright © 2021 402187526@qq.com. All rights reserved.
//

#import "XMExampleView.h"

@implementation XMExampleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

+ (NSString *)routerKey {
    return @"customView";
}

//instance的属性已经被设置好
+ (void)customRouterWithInstance:(id)instance {
    if ([instance isKindOfClass:[XMExampleView class]]) {
        XMExampleView *view = (XMExampleView *)instance;
        NSLog(@"age=%d,name=%@",view.age,view.name);
        view.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

//这样也可以 但是对象的属性需要通过params自行设置
//+ (void)customRouteWithKey:(NSString *)key andParams:(NSDictionary *)params {
//
//    XMExampleView *view = [[XMExampleView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    view.age = [params[@"age"] intValue];
//    view.name = params[@"name"];
//
//    [[UIApplication sharedApplication].keyWindow addSubview:view];
//
//}

@end
