//
//  XMRouterManager.m
//  XMRouter
//
//  Created by 李明 on 2021/1/15.
//

#import "XMRouterManager.h"

@interface XMRouterManager ()
//路由字典
@property(nonatomic) NSMutableDictionary *routes;

@end

@implementation XMRouterManager

+ (instancetype)share {
    static XMRouterManager *shareInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareInstance = [[XMRouterManager alloc] init];
    });
    return shareInstance;
}

- (void)registerGlobalRouters:(NSDictionary *)routers {
    
    NSMutableDictionary *res = [[NSMutableDictionary alloc] init];
    for (NSString  *key in routers.allKeys){
        id value = routers[key];
        if ([value isKindOfClass:[NSString class]]) {
            Class class = NSClassFromString(value);
            if (class) {
                [res setObject:class forKey:key];
            }
        }
        else {
            [res setObject:value forKey:key];
        }
    }
    
    if (res) {
        [self.routes addEntriesFromDictionary:res];
    }
}

- (NSError *)registerClassRouter:(Class)class withRouterKey:(NSString *)routerKey {
    
    if (self.routes[routerKey]) {
        NSAssert(NO, @"重复router");
        return [NSError errorCode:XMRouterErrorCodeRepeatRouter withDescription:@"重复router"];
    }
    [self.routes setObject:class forKey:routerKey];
    return nil;
}


- (Class)getRouterWithRoutName:(NSString *)routeName error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    if (routeName.length == 0) {
        *error = [NSError errorCode:XMRouterErrorCodeRouterError withDescription:@"错误的routerName"];
    }
    return self.routes[routeName];
}

#pragma mark lazyloading

- (NSMutableDictionary *)routes {
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}

@end

#define XMRouterDomain @"com.xmrouter"

@implementation NSError(XMRouter)

+ (NSError *)errorCode:(NSInteger)errorCode withDescription:(NSString *)description {
    return [NSError errorWithDomain:XMRouterDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:description}];
}

@end
