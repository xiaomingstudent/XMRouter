//
//  XMRouterDelegate.h
//  XMRouter
//
//  Created by 李明 on 2021/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XMRouterDelegate <NSObject>
@optional
/**
 路由地址
 */
+ (NSString *)routerKey;

/**
 自定义路由跳转 直接返回实例对象 属性已被设置
 */
+ (void)customRouterWithInstance:(id)instance;

/**
 自定义路由跳转方式 自定义程度更高 实现了此方法后customRouterWithInstance:将不会执行
 */
+ (void)customRouteWithKey:(NSString *)key andParams:(NSDictionary *)params;

/**
 设置params中的key与property的转换
 */
+ (NSDictionary *)ReplacedKeyFromPropertyName;

/**
 某一个路由param是否需要自定义方法param转换成property
 */
+ (BOOL)shouldCustomTransform:(NSString *)propertyName;

/**
 自定义参数转换成属性的方法
 */
+ (id)customParam:(id)param toPropertyValueWithPropertyName:(NSString *)propertyName;

@end

NS_ASSUME_NONNULL_END
