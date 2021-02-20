#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XMRouter.h"
#import "XMRouterDelegate.h"
#import "XMRouterManager.h"
#import "XMRouterRuntimeSupport.h"

FOUNDATION_EXPORT double XMRouterVersionNumber;
FOUNDATION_EXPORT const unsigned char XMRouterVersionString[];

