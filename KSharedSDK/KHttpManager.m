//
//  KHttpManager.m
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KHttpManager.h"

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
{
    _success = success;
    _failure = failure;
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
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
