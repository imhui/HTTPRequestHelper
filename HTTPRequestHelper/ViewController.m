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
    
    HTTPRequestHelper *client = [[HTTPRequestHelper alloc] initWithTarget:self selector:@selector(dataDidReceived:)];
    [client get:@"http://www.google.com" params:[NSDictionary dictionary]];
    [client release];
    
}

- (void)dataDidReceived:(id)data {
    HTTPLOG(@"data: %@", data);
}

@end
