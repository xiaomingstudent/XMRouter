# XMRouter


[![Version](https://img.shields.io/cocoapods/v/XMRouter.svg?style=flat)](https://cocoapods.org/pods/XMRouter)
[![Platform](https://img.shields.io/cocoapods/p/XMRouter.svg?style=flat)](https://cocoapods.org/pods/XMRouter)

## Example

首先在 application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions注册
```objc
[[XMRouter shared] registerWithConfig:[XMConfig new]];
```
注册路由 两种方式：
全局注册:
实现XMRouterConfigProtocol的globlaRouters方法
```objc
//全局注册，在这里注册之后 就不用实现routerkey方法
- (NSDictionary *)globlaRouters {
    return @{
        @"presentVC":@"XMPresentViewController",
        @"paramsExampleVC":[XMParamsExampleViewController class],
    };
}
```

2.在任意类里面实现
```objc
+ (NSString *)routerKey {
    return @"presentVC";
}
```
跳转：
1.通过routerName跳转
```objc
[XMRouter routeWithName:@"presentVC" withParams:@{@"aTitle":@"hello",@"aAge":@"11"} routeType:XMRouterTypePush];
```
2.通过routerUrl跳转
```objc
[XMRouter routeWithUrl:@"xmrouter://presentVC?aTitle=hello&aAge=11&XMRouteType=1"];
```
传参：
1.直接传参：
当参数和属性名相同时自动设置属性

参数映射：实现这个方法后可以根据params重新映射到属性
```objc
+ (NSDictionary *)ReplacedKeyFromPropertyName {
    return @{@"name":@"aName"};
}
```
2.手动传参：
参数可以自己手动进行转换 参考examle里的XMParamsExampleViewController
```objc
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

```
手动跳转：
非UIViewController的类需要自己实现跳转方法
//instance的属性已经被设置好
```objc
+ (void)customRouterWithInstance:(id)instance {
    if ([instance isKindOfClass:[XMExampleView class]]) {
        XMExampleView *view = (XMExampleView *)instance;
        NSLog(@"age=%d,name=%@",view.age,view.name);
        view.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

//对象的属性需要通过params自行设置

+ (void)customRouteWithKey:(NSString *)key andParams:(NSDictionary *)params {

    XMExampleView *view = [[XMExampleView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.age = [params[@"age"] intValue];
    view.name = params[@"name"];


    [[UIApplication sharedApplication].keyWindow addSubview:view];

}
```

## Installation

XMRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XMRouter'
```

## Author

402187526@qq.com,

## License

XMRouter is available under the MIT license. See the LICENSE file for more info.
