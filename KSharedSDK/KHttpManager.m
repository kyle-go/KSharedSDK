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
    NSMutableURLRequest *_request;
    
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

- (NSMutableURLRequest *)getRequest:(NSString *)URLString parameters:(NSDictionary *)parameters
    success:(void (^)(id))success
    failure:(void (^)(NSError *))failure
{
    _success = success;
    _failure = failure;
    NSURL *url = [KUnits generateURL:URLString params:parameters];
    _request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    //content-length
    NSRange range = [[url absoluteString] rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        NSString *length = [NSString stringWithFormat:@"%ld", (long)([url absoluteString].length - range.location - 1)];
        [_request setValue:length forHTTPHeaderField:@"content-length"];
    }
    
    return _request;
}

- (void)start
{
    if (_request) {
        _urlConnection = [[NSURLConnection alloc]initWithRequest:_request delegate:self];
    }
    _request = nil;
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
