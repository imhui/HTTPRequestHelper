//
//  HTTPRequestHelper.m
//  HTTPRequestHelper
//
//  Created by LiYonghui on 12-10-12.
//  Copyright (c) 2012年 LiYonghui. All rights reserved.
//

#import "HTTPRequestHelper.h"

#define kFORM_BOUNDARY_STRING       @"0xKhTmLbOuNdArY"
#define kNETWORK_POST_TIMEOUT       80.0
#define kNETWORK_GET_TIMEOUT        60.0


@interface NSString (URLEncode_Decode)
+ (NSString *)encodedString:(NSString *)str;
+ (NSString *)decodedString:(NSString *)str;

@end

@implementation NSString (URLEncode_Decode)

+ (NSString *)encodedString:(NSString *)str {
    
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
	return [result autorelease];
}

+ (NSString *)decodedString:(NSString *)str {
    
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)str,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
	return [result autorelease];
}


@end


@interface HTTPRequestHelper () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    NSMutableData *_bufData;
    NSInteger _statusCode;
}

+ (NSData *)prepareFormParams:(NSDictionary *)params;
+ (NSData *)prepareFormData:(NSData *)data key:(NSString *)key;
+ (NSString *)prepareParamsString:(NSDictionary *)params;
+ (NSString *)prepareUrl:(NSString *)url params:(NSDictionary *)params;




@end

@implementation HTTPRequestHelper
@synthesize statusCode = _statusCode;


- (void)dealloc
{
    if (_connection != nil) {
        [_connection release];
        _connection = nil;
    }
    
    if (_bufData != nil) {
        [_bufData release];
        _bufData = nil;
    }
    
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _connection = nil;
        _target = nil;
    }
    return self;
}


- (id)initWithTarget:(id)target selector:(SEL)sel {
    if (self = [self init]) {
        _target = target;
        _selector = sel;
    }
    return self;
}


#pragma mark
+ (NSData *)prepareFormParams:(NSDictionary *)params {

    HTTPLOG(@"params: %@", params);
    NSMutableData *retData = [NSMutableData dataWithCapacity:0];
    
    NSArray *allKeys = [params allKeys];
    for (NSInteger i = 0; i < [allKeys count]; i++) {
        
        NSString *key = [allKeys objectAtIndex:i];
        NSString *val = [NSString encodedString:[params objectForKey:key]];
        
        [retData appendData:[[NSString stringWithFormat:@"--%@\r\n", kFORM_BOUNDARY_STRING] dataUsingEncoding:NSUTF8StringEncoding]];
        [retData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [retData appendData:[[NSString stringWithFormat:@"%@\r\n", val] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    return retData;
    
}

+ (NSData *)prepareFormData:(NSData *)data key:(NSString *)key {
    
    NSMutableData *retData = [NSMutableData dataWithCapacity:0];
    
    [retData appendData:[[NSString stringWithFormat:@"--%@\r\n", kFORM_BOUNDARY_STRING] dataUsingEncoding:NSUTF8StringEncoding]];
    [retData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [retData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [retData appendData:data];
    [retData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return retData;
    
}

+ (NSData *)prepareFormFooter {
    NSString *footer = [NSString stringWithFormat:@"--%@--\r\n", kFORM_BOUNDARY_STRING];
    return [footer dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSURLRequest *)preparePostRequest:(NSString *)url params:(NSDictionary *)params data:(NSData *)jpeg dataKey:(NSString *)dataKey {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:kNETWORK_POST_TIMEOUT];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kFORM_BOUNDARY_STRING];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jpeg length]] forHTTPHeaderField:@"Content-Length"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[self prepareFormParams:params]];
    [body appendData:[self prepareFormData:jpeg key:dataKey]];
    [body appendData:[self prepareFormFooter]];
    
    [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    return request;
}


+ (NSString *)prepareParamsString:(NSDictionary *)params {
    
    NSMutableString *retString = [NSMutableString stringWithString:@""];
    
    NSArray *allKeys = [params allKeys];
    for (NSInteger i = 0; i < [allKeys count]; i++) {
        
        if (i > 0) {
            [retString appendString:@"&"];
        }
        
        NSString *key = [allKeys objectAtIndex:i];
        NSString *val = [NSString encodedString:[params objectForKey:key]];
        [retString appendFormat:@"%@=%@", key, val];
        
    }
    
    return retString;
    
}

+ (NSString *)prepareUrl:(NSString *)url params:(NSDictionary *)params {
    
    NSMutableString *retUrl = [NSMutableString stringWithString:url];
    
    NSString *query = @"";
    if (params != nil) {
        
        NSMutableArray *querys = [NSMutableArray arrayWithCapacity:0];
        for (NSString *key in params) {
            [querys addObject:[NSString stringWithFormat:@"%@=%@", key, [NSString encodedString:[params objectForKey:key]]]];
        }
        query = [querys componentsJoinedByString:@"&"];
    }
    
    if ([query length] > 0) {
        [retUrl appendFormat:@"?%@", query];
    }
    
    return retUrl;
}

#pragma mark
- (void)cancel {
    if (_connection != nil) {
        [_connection cancel];
    }
}

- (void)get:(NSString *)url params:(NSDictionary *)params {
    
    NSString *reqUrl = [[self class] prepareUrl:url params:params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:kNETWORK_GET_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    
    NSString *contentType = @"application/x-www-form-urlencoded";
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"Mobile Safari 1.1.3 (iPhone; U; CPU like Mac OS X; en)" forHTTPHeaderField:@"User-Agent"];
    
    HTTPLOG(@"%@", request.URL.absoluteString);
    
    _bufData = [[NSMutableData alloc] initWithCapacity:0];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_connection start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (id)getSyncRequest:(NSString *)url {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:kNETWORK_GET_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    
    NSString *contentType = @"application/x-www-form-urlencoded";
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    if (error != nil) {
        return error;
    }
    else {
        NSString* s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [s autorelease];
    }
    
}

- (void)post:(NSString *)url params:(NSDictionary *)params {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:kNETWORK_POST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = @"application/x-www-form-urlencoded";
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSString *body = [[self class] prepareParamsString:params];
    NSInteger contentLength = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    _bufData = [[NSMutableData alloc] initWithCapacity:0];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_connection start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)post:(NSString *)url params:(NSDictionary *)params data:(NSData *)jpeg dataKey:(NSString *)dataKey {
    
    NSURLRequest *request = [[self class] preparePostRequest:url params:params data:jpeg dataKey:dataKey];
    _bufData = [[NSMutableData alloc] initWithCapacity:0];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_connection start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (id)postSyncRequest:(NSString *)url params:(NSDictionary *)params data:(NSData *)jpeg dataKey:(NSString *)dataKey {
    
    NSURLRequest *request = [[self class] preparePostRequest:url params:params data:jpeg dataKey:dataKey];
    HTTPLOG(@"request: %@", request.URL.absoluteString);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    _statusCode = resp.statusCode;
    
    if (error != nil) {
        return error;
    }
    else {
        NSString* s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return s;
    }
    
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    HTTPLOG(@"response: %@", response);
    NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
    if (resp) {
        _statusCode = resp.statusCode;
    }
	[_bufData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_bufData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* s = [[[NSString alloc] initWithData:_bufData encoding:NSUTF8StringEncoding] autorelease];
    [self performSelectorOnMainThread:@selector(httpRequestDidFinishLoading:) withObject:s waitUntilDone:NO];
//    [self httpRequestDidFinishLoading:s];
    
    [_connection release];
    _connection = nil;
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self performSelectorOnMainThread:@selector(httpRequestDidFailWithError:) withObject:error waitUntilDone:NO];
//    [self httpRequestDidFailWithError:error];
    
    [_connection release];
    _connection = nil;
}

//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//
//}


#pragma mark - connection finish callback
- (void)httpRequestDidFinishLoading:(NSString *)content {
    HTTPLOG(@"%@", content);
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:content];
    }

}

- (void)httpRequestDidFailWithError:(NSError *)error {
    HTTPLOG(@"%@", error);
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:error];
    }

}


@end
