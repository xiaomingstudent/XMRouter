//
//  XMRouter.m
//  XMRouter
//
//  Created by 李明 on 2021/1/22.
//

#import "XMRouter.h"
#import "XMRouterManager.h"
#import "XMRouterDelegate.h"
#import "XMRouterRuntimeSupport.h"
#import <objc/runtime.h>
#import <dlfcn.h>

@interface XMRouterManager()

- (void)registerGlobalRouters:(NSDictionary *)routers;

@end


@interface XMRouter()

@property(nonatomic) id<XMRouterConfigProtocol> config;

@end


@implementation XMRouter

+ (instancetype)shared {
    static XMRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[XMRouter alloc] init];
    });
    return router;
}

- (void)registerWithConfig:(id<XMRouterConfigProtocol>)config {
    _config = config;
    if ([config respondsToSelector:@selector(globlaRouters)]) {
        [[XMRouterManager share] registerGlobalRouters:[config globlaRouters]];
    }
    
    unsigned int count;
    const char **classes;
    Dl_info info;
    
    void *_mh_execute_header = __builtin_return_address(0);
    dladdr(_mh_execute_header, &info);
    
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    for (int i = 0; i < count; i++) {
        NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        if ([class conformsToProtocol:@protocol(XMRouterDelegate)]) {
            if ([class respondsToSelector:@selector(routerKey)]) {
                NSError *error = [[XMRouterManager share] registerClassRouter:class withRouterKey:[class routerKey]];
                if (error) {
                    if ([self.config respondsToSelector:@selector(dealRouteError:)]) {
                        [self.config dealRouteError:error];
                    }
                }
            }
        }
    }
}

+ (void)routeWithName:(NSString *)routerName {
    [self routeWithName:routerName withParams:nil];
}

+ (void)routeWithName:(NSString *)routerName withParams:(nullable NSDictionary *)params {
    [self routeWithName:routerName withParams:params routeType:XMRouterTypePush];
}

+ (void)routeWithUrl:(NSString *)routerUrl withOtherParams:(NSDictionary *)params {
    if (routerUrl.length == 0) {
        NSAssert(NO, @"路由地址为空");
        [[XMRouter shared] castErrorWithErrorCode:XMRouterErrorCodeURLError andDescription:@"路由地址为空"];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:routerUrl];
    NSString *appScheme = nil;
    if ([[XMRouter shared].config respondsToSelector:@selector(appScheme)]) {
        appScheme = [[XMRouter shared].config appScheme];
    }
    if ([url.scheme hasPrefix:@"http"] || [url.scheme hasPrefix:@"https"]) {
        if ([[XMRouter shared].config respondsToSelector:@selector(openHttpRoute:)]) {
            [[XMRouter shared].config openHttpRoute:routerUrl];
        }
    }
    else if(appScheme.length > 0 && [url.scheme hasPrefix:appScheme]) {
        [self jumpWithUrl:url withOtherParams:params];
    }
    else {
        BOOL res = [[UIApplication sharedApplication] openURL:url];
        if (!res) {
            
        }
    }
}


+ (void)routeWithUrl:(NSString *)routerUrl {
    [self routeWithUrl:routerUrl withOtherParams:nil];
}


+ (void)routeWithName:(NSString *)routerName withParams:(NSDictionary *)params routeType:(XMRouterType)routType {
    [[XMRouter shared] routeWithName:routerName withParams:params routeType:routType];
}


//核心方法
- (void)routeWithName:(NSString *)routerName withParams:(nullable NSDictionary *)params routeType:(XMRouterType)routType {
    
    NSError *error = nil;
    Class router = [[XMRouterManager share] getRouterWithRoutName:routerName error:&error];
    if (error) {
        if ([self.config respondsToSelector:@selector(dealRouteError:)]) {
            [self.config dealRouteError:error];
        }
        return;
    }
    id routerInstance = [[router alloc] init];
    
    NSDictionary *replaceKeyFromPropertyName = nil;
    NSDictionary *keyMap = [self reverseDictionary:replaceKeyFromPropertyName];
    if ([router isSubclassOfClass:[NSObject class]] && [router conformsToProtocol:@protocol(XMRouterDelegate)]) {
        if ([router respondsToSelector:@selector(ReplacedKeyFromPropertyName)]) {
            replaceKeyFromPropertyName = [router ReplacedKeyFromPropertyName];
            keyMap = [self reverseDictionary:replaceKeyFromPropertyName];
        }
        NSArray<XMProperty *> *properties = [XMRouterRuntimeSupport getAllPropertiesWithObject:router];
        for (XMProperty *property in properties) {
            NSString *paramKey = replaceKeyFromPropertyName[property.propertyName];
            if (!paramKey) paramKey = property.propertyName;
            if ([router respondsToSelector:@selector(shouldCustomTransform:)]) {
                BOOL customTransForm = [router  shouldCustomTransform:property.propertyName];
                if (customTransForm) {
                    if ([router respondsToSelector:@selector(customParam:toPropertyValueWithPropertyName:)]) {
                        id value = [router customParam:params[paramKey] toPropertyValueWithPropertyName:property.propertyName];
                        [routerInstance setValue:value forKey:property.propertyName];
                    }
                    else {
                        NSAssert(NO, @"必须实现customParam:toPropertyValueWithPropertyName:方法");
                        [self castErrorWithErrorCode:XMRouterErrorCodeParamError andDescription:@"必须实现customParam:toPropertyValueWithPropertyName:方法"];
                    }
                }
                else {
                    [self setValue:params[paramKey] forProperty:property forObjct:routerInstance];
                }
            }
            else {
                [self setValue:params[paramKey] forProperty:property forObjct:routerInstance];
            }
            
        }
        if ([router isSubclassOfClass:[UIViewController class]]) {
            [self JumpRouter:(UIViewController *)routerInstance routeType:routType];
        }
        else {
            if ([router respondsToSelector:@selector(customRouteWithKey:andParams:)]) {
                [router customRouteWithKey:routerName andParams:params];
                return;
            }
            else if ([router respondsToSelector:@selector(customRouterWithInstance:)]) {
                [router customRouterWithInstance:routerInstance];
            }
            else {
                NSAssert(NO, @"非UIViewController子类须实现customRouteWithKey:andParams:或者customRouterWithInstance:自定义路由跳转方式");
                [self castErrorWithErrorCode:XMRouterErrorCodeNotFindCustomRoute andDescription:@"非UIViewController子类须实现customRouteWithKey:andParams:或者customRouterWithInstance:自定义路由跳转方式"];
            }
        }

    }
}

#pragma mark private

+ (void)jumpWithUrl:(NSURL *)url withOtherParams:(NSDictionary *)otherParams {
    
    NSString *host = url.host;
    NSString *path = url.path;
    
    NSString *routerName = [NSString stringWithFormat:@"%@%@",host ? host : @"",path ? path : path];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (otherParams) {
        [params addEntriesFromDictionary:otherParams];
    }
    NSString *paramsString = [url.absoluteString componentsSeparatedByString:@"?"].lastObject;
    NSDictionary *urlParams = [self getParamDictionaryWithParamString:paramsString];
    if (urlParams) {
        [params addEntriesFromDictionary:urlParams];
    }
    XMRouterType type = XMRouterTypePush;
    if (params[routeTypeKey]) {
        type = [params[routeTypeKey] intValue];
    }
    
    [self routeWithName:routerName withParams:params routeType:type];
    
}

- (void)JumpRouter:(UIViewController *)vc routeType:(XMRouterType)routeType{
    
    switch (routeType) {
        case XMRouterTypePush:
            if ([self topNavigationController]) {
                [[self topNavigationController] pushViewController:vc animated:YES];
            }
            else {
                NSAssert(NO, @"不存在navigationController");
                [self castErrorWithErrorCode:XMRouterErrorCodeNotFindNavigation andDescription:@"不存在navigationController"];
            }
            break;
        case XMRouterTypePresent:
            [[self topViewController] presentViewController:vc animated:YES completion:nil];
            break;
        case XMRouterTypePopPush:{
            UINavigationController *naviVc = [self topNavigationController];
            BOOL hasSubVc = NO;
            if (naviVc) {
                for (UIViewController *subVC in naviVc.viewControllers) {
                    if ([subVC isKindOfClass:[vc class]]) {
                        [naviVc popToViewController:subVC animated:YES];
                        hasSubVc = YES;
                        break;
                    }
                }
                if (!hasSubVc) {
                    [[self topNavigationController] pushViewController:vc animated:YES];
                }
            }
            else {
                NSAssert(NO, @"不存在navigationController");
                [self castErrorWithErrorCode:XMRouterErrorCodeNotFindNavigation andDescription:@"不存在navigationController"];
            }
        }
            break;
        default:
            break;
    }
    
}


- (UIViewController *)topViewController {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}


- (UINavigationController *)topNavigationController {
    
    UINavigationController *naviVc = nil;
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            naviVc = (UINavigationController *)vc;
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return naviVc;
    
}



- (void)setValue:(id)value forProperty:(XMProperty *)property forObjct:(NSObject *)object {
    
    if (value && [value isKindOfClass:[NSString class]]) {
        if ([value isKindOfClass:[NSNull class]]) {
            return;
        }
        if ([value isKindOfClass:[NSString class]]) {
            if (!property.isObject) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter numberFromString:value];
                if (!value) {
                    value = @(0);
                }
                [object setValue:value forKey:property.propertyName];
            }
            else {
                if (property.isNSNumber) {
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter numberFromString:value];
                    if (!value) {
                        value = @(0);
                    }
                    if ([property.propertyName.lowercaseString containsString:@"mutable"]) {
                        [object setValue:[value mutableCopy] forKey:property.propertyName];
                    }
                    else {
                        [object setValue:value forKey:property.propertyName];
                    }
                }
                else if (property.isNSString) {
                    if ([property.propertyName.lowercaseString containsString:@"mutable"]) {
                        [object setValue:[value mutableCopy] forKey:property.propertyName];
                    }
                    else {
                        [object setValue:value forKey:property.propertyName];
                    }
                }
                else {
                    NSAssert(NO, @"其他类型须实现customParam:toPropertyValueWithPropertyName:自行转换");
                    [self castErrorWithErrorCode:XMRouterErrorCodeParamError andDescription:@"其他类型须实现customParam:toPropertyValueWithPropertyName:自行转换"];
                }
            }
        }
    }
    else {
        if (value) {
            NSAssert(NO, @"params不为NSString时须实现customParam:toPropertyValueWithPropertyName:自行转换");
            [self castErrorWithErrorCode:XMRouterErrorCodeParamError andDescription:@"params不为NSString时须实现customParam:toPropertyValueWithPropertyName:自行转换"];
        }
    }
    
}



+ (NSDictionary *)getParamDictionaryWithParamString:(NSString *)paramString {
    if (![paramString containsString:@"="]) {
        return nil;
    }
    NSArray *keyValues = [paramString componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *keyValue in keyValues) {
        if (![keyValue containsString:@"="]) {
            continue;
        }
        NSRange range = [keyValue rangeOfString:@"="];
        NSString *key = [keyValue substringToIndex:range.location];
        NSString *value = [keyValue substringFromIndex:range.location + 1];
        if (key && value) {
            params[key] = value;
        }
    }
    return params;
}

- (NSDictionary *)reverseDictionary:(NSDictionary *)dica {
    
    NSMutableDictionary *reverseDica = [NSMutableDictionary dictionary];
    for (id key in dica.allKeys) {
        id value = dica[key];
        if (key && value) {
            reverseDica[value] = key;
        }
    }
    return reverseDica;
}

- (void)castErrorWithErrorCode:(NSInteger)errorCode andDescription:(NSString *)description {
    NSError *error = [NSError errorCode:errorCode withDescription:description];
    if ([self.config respondsToSelector:@selector(dealRouteError:)]) {
        [self.config dealRouteError:error];
    }
}


@end


