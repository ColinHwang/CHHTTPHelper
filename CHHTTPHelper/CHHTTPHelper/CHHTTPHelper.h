//
//  CHHTTPHelper.h
//  CHHTTPHelper
//
//  Created by colin on 16/7/4.
//  Copyright © 2016年 CHwang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CHHTTPRequestSuccess)(NSURLSessionDataTask *task, id responseObject);
typedef void(^CHHTTPRequestFailure)(NSURLSessionDataTask *task, NSError *error, NSString *exCode, NSString *exMsg);
typedef void(^CHHTTPRequestAllCompletion)();

@interface CHHTTPHelper : NSObject

+ (CHHTTPHelper *)defaultHTTPHelper;

#pragma mark - API Path
+ (NSString *)URLWithModule:(NSString *)module APIPath:(NSString *)APIPath;

#pragma mark - Request Method
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion;

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion;

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion;

- (NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion;

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion;

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion;

@end
