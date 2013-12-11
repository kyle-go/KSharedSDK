//
//  KHttpManager.m
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KHttpManager.h"
#import "KUnits.h"

@interface KHttpManager() <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@end

@implementation KHttpManager {
    NSMutableData *_responseData;
    NSURLConnection *_urlConnection;
    
    void (^_success)(id);
    void (^_failure)(NSError *);
}

- (id)init
{
    if (self = [super init]) {
        _responseData = [[NSMutableData alloc] init];
    }
    return self;
}

+ (KHttpManager *) manager
{
    return [[KHttpManager alloc] init];
}

- (void)GET:(NSString *)URLString parameters:(NSDictionary *)parameters
    success:(void (^)(id))success
    failure:(void (^)(NSError *))failure
    content_type:(NSString *)content_type
{
    _success = success;
    _failure = failure;
    NSURL *url = [KUnits generateURL:URLString params:parameters];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //content-type
    if (content_type) {
        [request setValue:content_type forHTTPHeaderField:@"content-type"];
    }
    
    //content-length
    NSRange range = [[url absoluteString] rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        NSString *length = [NSString stringWithFormat:@"%ld", (long)([url absoluteString].length - range.location - 1)];
        [request setValue:length forHTTPHeaderField:@"content-length"];
    }
    _urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters
    success:(void (^)(id))success
    failure:(void (^)(NSError *))failure
    content_type:(NSString *)content_type
{
    _success = success;
    _failure = failure;
    NSURL *url = [KUnits generateURL:URLString params:parameters];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    
    //content-type
    if (content_type) {
        [request setValue:content_type forHTTPHeaderField:@"content-type"];
    }

    //content-length
    NSRange range = [[url absoluteString] rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        NSString *length = [NSString stringWithFormat:@"%ld", (long)([url absoluteString].length - range.location - 1)];
        [request setValue:length forHTTPHeaderField:@"content-length"];
    }
    
    _urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

#pragma mark ---- NSURLConnectionDataDelegate -----
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    //NSLog(@"%@",[res allHeaderFields]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    _success(receiveStr);
}

#pragma mark ---- NSURLConnectionDelegate -----
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _failure(error);
}

@end
