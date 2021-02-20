//
//  XMRouterRuntimeSupport.m
//  XMRouter
//
//  Created by 李明 on 2021/1/15.
//

#import "XMRouterRuntimeSupport.h"
#import <objc/runtime.h>

@implementation XMRouterRuntimeSupport

+ (void)methodswizzlingWithClass:(Class)clas originalSelector:(SEL)originalSel swizzlingSelector:(SEL)swizzlingSel {
    
    Method originalMethod = class_getClassMethod(clas, originalSel);
    Method swizzlingMethod = class_getClassMethod(clas, swizzlingSel);
    
    if (class_addMethod(clas, originalSel, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod))) {
        class_replaceMethod(clas, swizzlingSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }

}

+ (NSArray<XMProperty *> *)getAllPropertiesWithObject:(id)object {
    
    Class class = [object class];
    NSMutableArray *propertiesArray = [[NSMutableArray alloc] init];;
    
    while (class != [NSObject class]) {
        u_int count;
        objc_property_t *properties  =class_copyPropertyList(class, &count);
        for (int i = 0; i<count; i++)
        {
            objc_property_t property= properties[i];
            NSString *propertyName = @(property_getName(property));
            if ([propertyName isEqualToString:@"hash"]) continue;
            else if ([propertyName isEqualToString:@"superclass"]) continue;
            else if ([propertyName isEqualToString:@"description"]) continue;
            else if ([propertyName isEqualToString:@"debugDescription"]) continue;
            else if ([propertyName hasPrefix:@"tmp_"]) continue;
            else if ([propertyName isEqualToString:@"format_error"]) continue;
            NSString *attrs = @(property_getAttributes(property));
            NSUInteger dotLoc = [attrs rangeOfString:@","].location;
            NSString *code = nil;
            NSUInteger loc = 1;
            if (dotLoc == NSNotFound) {
                code = [attrs substringFromIndex:loc];
            } else {
                code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
            }
            
            XMProperty *xmProperty = [[XMProperty alloc] init];
            xmProperty.propertyName = propertyName;
            if ([code hasPrefix:@"@\""]) {
                xmProperty.isObject = YES;
                if (code.length > 3) {
                    xmProperty.typeName = [code substringWithRange:NSMakeRange(2, code.length - 3)];
                }
            }
            if (xmProperty.typeName && [NSClassFromString(xmProperty.typeName) isSubclassOfClass:[NSString class]]) {
                xmProperty.isNSString = YES;
            }
            if (xmProperty.typeName && [NSClassFromString(xmProperty.typeName) isSubclassOfClass:[NSNumber class]]) {
                xmProperty.isNSNumber = YES;
            }
            [propertiesArray addObject:xmProperty];
            
        }
        free(properties);
        class = class_getSuperclass(class);
    }
    
    return propertiesArray;
}


@end


@implementation XMProperty
@end
