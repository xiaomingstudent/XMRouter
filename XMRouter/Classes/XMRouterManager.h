//
//  XMRouterManager.h
//  XMRouter
//
//  Created by 李明 on 2021/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XMRouterConfigProtocol <NSObject>

/**
 app的scheme 决定路由是跳转app内部或者其他处理方式
 */
- (NSString *)appScheme;

@optional
/**
 全局路由注册，在这里注册之后 就不用实现XMRouterDelegate的routerKey方法
 */
- (NSDictionary *)globlaRouters;
/**
 处理XMRouter抛出来的error
 */
- (void)dealRouteError:(NSError *)error;
/**
 当路由地址是scheme为http时会调用这个方法 可以在这里用自己的webController打开地址
 */
- (void)openHttpRoute:(NSString *)httpUrl;


@end

@interface XMRouterManager : NSObject

+ (instancetype)share;

- (NSError *)registerClassRouter:(Class)class withRouterKey:(NSString *)routerKey;

- (Class)getRouterWithRoutName:(NSString *)routeName error:(NSError **)error;
 
@end

typedef NS_ENUM(NSUInteger, XMRouterErrorCode) {
    XMRouterErrorCodeRouterError = -10000,
    XMRouterErrorCodeURLError = -10001,
    XMRouterErrorCodeParamError = -10002,
    XMRouterErrorCodeNotFindCustomRoute = -10003,
    XMRouterErrorCodeNotFindNavigation = -10004,
    XMRouterErrorCodeRepeatRouter = -10005
};

@interface NSError (XMRouter)

+ (NSError *)errorCode:(NSInteger)errorCode withDescription:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
