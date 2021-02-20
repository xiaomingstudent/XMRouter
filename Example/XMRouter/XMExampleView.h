//
//  XMExampleView.h
//  XMRouter_Example
//
//  Created by 李明 on 2021/2/19.
//  Copyright © 2021 402187526@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMRouterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMExampleView : UIView<XMRouterDelegate>

@property(nonatomic) NSString *name;

@property(nonatomic) int age;

@end

NS_ASSUME_NONNULL_END
