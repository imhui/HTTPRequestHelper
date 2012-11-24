//
//  HTTPRequestHelper.h
//  HTTPRequestHelper
//
//  Created by LiYonghui on 12-10-12.
//  Copyright (c) 2012年 LiYonghui. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#define HTTPLOG(fmt,...)     NSLog((@"HTTP->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define HTTPLOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif

@interface HTTPRequestHelper : NSObject {
    id _target;
    SEL _selector;
    NSURLConnection *_connection;
}

@property (nonatomic, assign) NSInteger statusCode;

- (id)initWithTarget:(id)target selector:(SEL)sel;

- (void)get:(NSString *)url params:(NSDictionary *)params;
- (void)post:(NSString *)url params:(NSDictionary *)params;
- (void)post:(NSString *)url params:(NSDictionary *)params data:(NSData *)jpeg dataKey:(NSString *)dataKey;
- (id)postSyncRequest:(NSString *)url params:(NSDictionary *)params data:(NSData *)jpeg dataKey:(NSString *)dataKey;
+ (NSURLRequest *)preparePostRequest:(NSString *)url params:(NSDictionary *)params data:(NSData *)jpeg dataKey:(NSString *)dataKey;

- (void)httpRequestDidFinishLoading:(NSString *)content;
- (void)httpRequestDidFailWithError:(NSError *)error;


@end
