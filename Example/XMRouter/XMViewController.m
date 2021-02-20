//
//  XMViewController.m
//  XMRouter
//
//  Created by 402187526@qq.com on 01/15/2021.
//  Copyright (c) 2021 402187526@qq.com. All rights reserved.
//

#import "XMViewController.h"
#import <XMRouter.h>

@interface XMViewController ()

@end

@implementation XMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)present:(UIButton *)sender {
   // [XMRouter routeWithName:@"presentVC" withParams:@{@"aTitle":@"hello",@"aAge":@"11"} routeType:XMRouterTypePush];
    
    [XMRouter routeWithUrl:@"xmrouter://presentVC?aTitle=hello&aAge=11&XMRouteType=1"];
}

- (IBAction)push:(UIButton *)sender {
    
    [XMRouter routeWithName:@"presentVC" withParams:@{@"aTitle":@"hello",@"aAge":@"11"} routeType:XMRouterTypePush];
    
    //[XMRouter routeWithUrl:@"xmrouter://presentVC?aTitle=hello&aAge=11"];
}


- (IBAction)pramaExample:(UIButton *)sender {
    
   // [XMRouter routeWithName:@"paramsExampleVC" withParams:@{@"aName":@"liming",@"age":@"11",@"date":@([[NSDate date] timeIntervalSince1970]),@"peoples":@"liming"} routeType:XMRouterTypePush];
    
    [XMRouter routeWithUrl:[NSString stringWithFormat:@"xmrouter://paramsExampleVC?aName=liming&age=11&date=%f&peoples=liming",[[NSDate date] timeIntervalSince1970]]];
    
}


- (IBAction)customRouter:(UIButton *)sender {
    
    [XMRouter routeWithName:@"customView" withParams:@{@"age":@"11",@"name":@"liming"}];
    
}


@end
