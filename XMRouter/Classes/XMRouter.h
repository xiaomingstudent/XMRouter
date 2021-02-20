//
//  XMRouter.h
//  XMRouter
//
//  Created by 李明 on 2021/1/22.
//

#import <Foundation/Foundation.h>
#import "XMRouterManager.h"

#define routeTypeKey @"XMRouteType"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XMRouterType) {
    XMRouterTypePush = 0, //直接push到控制器
    XMRouterTypePresent = 1,//直接present过去
    XMRouterTypePopPush = 2,//先检查栈中是否已经存在控制器 有则直接pop到栈中控制器 没有则push到新的控制器
};

@interface XMRouter : NSObject

+ (instancetype)shared;

- (void)registerWithConfig:(id<XMRouterConfigProtocol>)config;

+ (void)routeWithName:(NSString *)routerName withParams:(nullable NSDictionary *)params routeType:(XMRouterType)routType;

+ (void)routeWithName:(NSString *)routerName withParams:(nullable NSDictionary *)params;

+ (void)routeWithUrl:(NSString *)routerUrl withOtherParams:(nullable NSDictionary *)params;

+ (void)routeWithName:(NSString *)routerName;

+ (void)routeWithUrl:(NSString *)routerUrl;


@end

NS_ASSUME_NONNULL_END
