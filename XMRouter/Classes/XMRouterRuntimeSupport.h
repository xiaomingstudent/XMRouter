//
//  XMRouterRuntimeSupport.h
//  XMRouter
//
//  Created by 李明 on 2021/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMRouterRuntimeSupport : NSObject

+ (void)methodswizzlingWithClass:(Class)swizzlingClass originalSelector:(SEL)originalSel swizzlingSelector:(SEL)swizzlingSel;

+ (NSArray *)getAllPropertiesWithObject:(id)object;


@end

@interface XMProperty : NSObject

@property(nonatomic) NSString *propertyName;

@property(nonatomic) NSString *typeName;

//是否为对象
@property(nonatomic) BOOL isObject;

//是否为字符串
@property(nonatomic) BOOL isNSString;

//是否为NSNumber
@property(nonatomic) BOOL isNSNumber;


@end

NS_ASSUME_NONNULL_END

