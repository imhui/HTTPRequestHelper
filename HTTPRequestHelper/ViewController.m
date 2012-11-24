//
//  ViewController.m
//  HTTPRequestHelper
//
//  Created by LiYonghui on 12-11-24.
//  Copyright (c) 2012年 LiYonghui. All rights reserved.
//

#import "ViewController.h"
#import "HTTPRequestHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *params = [NSDictionary dictionary];
    HTTPRequestHelper *client = [[HTTPRequestHelper alloc] initWithTarget:self selector:@selector(dataDidReceived:)];
    [client get:@"http://www.google.com" params:params];
//    [client post:@"http://www.google.com" params:params];
//    [client post:@"http://www.google.com" params:params data:[NSData data] dataKey:@"data_key"];
    [client release];
    
    
    
}

- (void)dataDidReceived:(id)data {
    HTTPLOG(@"data: %@", data);
}

@end
