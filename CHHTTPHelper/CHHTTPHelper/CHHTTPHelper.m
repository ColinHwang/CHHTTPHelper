//
//  CHHTTPHelper.m
//  CHHTTPHelper
//
//  Created by colin on 16/7/4.
//  Copyright © 2016年 CHwang. All rights reserved.
//

#import "CHHTTPHelper.h"
#import "APIConstants.h"
#import "AFNetworking.h"

#define Test 0

static NSString * const DEFAULT_EX_CODE = @"请求失败";
static NSString * const DEFAULT_EX_MSG = @"加载失败";

typedef NS_ENUM(NSInteger, CHNetworkProtocolType) {
    CHNetworkProtocolTypeNone = 0,
    CHNetworkProtocolTypeHTTP,
    CHNetworkProtocolTypeHTTPS,
    CHNetworkProtocolTypeFTP
};

typedef NS_ENUM(NSInteger, CHServerPortType) {
    CHServerPortTypeNone = 0,
    CHServerPortType1020 = 1020,
    CHServerPortType2030 = 2030,
};

@interface CHHTTPHelper ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation CHHTTPHelper

+ (CHHTTPHelper *)defaultHTTPHelper
{
    static CHHTTPHelper *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.manager = [AFHTTPSessionManager manager];
        
        self.manager.requestSerializer.timeoutInterval = 10; // 请求时长
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/plain", @"application/json", @"text/json", @"text/javascript", @"text/html", @"image/png", nil];
        
//        self.manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    }
    return self;
}

#pragma mark - API Path
/**
 *  BASE_HOST -> www.abc.com
 */
+ (NSString *)baseHost
{
#ifdef DEBUG
    return BASE_HOST_DEVELOPER; // change
//    return BASE_HOST_PUPLIC; // change
#else
    return BASE_HOST_PUPLIC;
#endif
}

/**
 *  HOST -> http://www.abc.com
 */
+ (NSString *)host
{
    static NSString *host = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        host = [CHHTTPHelper hostPathURLWithNetworkProtocol:CHNetworkProtocolTypeHTTP baseHost:[CHHTTPHelper baseHost] portType:CHServerPortTypeNone];
    });
    
    return host;
}

/**
 *  HOST_PATH -> http://www.abc.com:1020
 */
+ (NSString *)hostPath
{
    static NSString *hostPath = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[CHHTTPHelper baseHost] isEqualToString:BASE_HOST_DEVELOPER])
        {
            hostPath = [CHHTTPHelper hostPathURLWithNetworkProtocol:CHNetworkProtocolTypeHTTP baseHost:[CHHTTPHelper baseHost] portType:CHServerPortType1020];
            return;
        }
        
        hostPath = [CHHTTPHelper hostPathURLWithNetworkProtocol:CHNetworkProtocolTypeHTTP baseHost:[CHHTTPHelper baseHost] portType:CHServerPortType2030];
    });
    
    return hostPath;
}

+ (NSString *)hostPathURLWithNetworkProtocol:(CHNetworkProtocolType)protocolType baseHost:(NSString *)baseHost portType:(CHServerPortType)portType
{
    NSString *URLString = [CHHTTPHelper networkProtocol:protocolType];
    
    URLString = [URLString stringByAppendingString:baseHost];
    
    return [URLString stringByAppendingString:[CHHTTPHelper port:portType]];
}

+ (NSString *)networkProtocol:(CHNetworkProtocolType)protocolType
{
    NSString *protocolString = @"";
    
    if (protocolType == CHNetworkProtocolTypeNone)
    {
        return protocolString;
    }
    
    if (protocolType == CHNetworkProtocolTypeHTTP)
    {
        protocolString = @"http";
    }
    
    if (protocolType == CHNetworkProtocolTypeHTTPS)
    {
        protocolString = @"https";
    }
    
    if (protocolType == CHNetworkProtocolTypeFTP)
    {
        protocolString = @"ftp";
    }
    
    return [protocolString stringByAppendingString:@"://"];
}

+ (NSString *)port:(CHServerPortType)portType
{
    NSString *portString = @"";
    
    if (portType == CHServerPortTypeNone) return portString;
    
    return [@":" stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)portType]]; // :1020
}

+ (NSString *)URLWithModule:(NSString *)module APIPath:(NSString *)APIPath
{
    return [[[CHHTTPHelper hostPath] stringByAppendingPathComponent:module] stringByAppendingPathComponent:APIPath];
}

#pragma mark - Private Method
/**
 *  配置请求成功回调(处理result为0情况)
 */
+ (void)configureRequestSuccess:(CHHTTPRequestSuccess)success requestFailure:(CHHTTPRequestFailure)failure withTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
#if Test
    /*  若项目返回数据如下：则可开启测试。也可以根据自身数据类型，自行配置
         请求成功：
         {
             "result":1,
             ...
         }
         
         请求失败：
         {
             "result":0,
             "exCode":"100",
             "exMsg":"失败"
         }
     **/
    if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        if ([responseObject[@"result"] intValue] == 1)
        {
            [CHHTTPHelper configureRequestSuccess:success withTask:task responseObject:responseObject];
            return;
        }
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task responseObject:responseObject];
        return;
    }
#else
    [CHHTTPHelper configureRequestSuccess:success withTask:task responseObject:responseObject];
#endif
}

/**
 *  配置请求成功回调
 */
+ (void)configureRequestSuccess:(CHHTTPRequestSuccess)success withTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    !success?:success(task, responseObject);
}

/**
 *  配置请求失败回调(无responseObject)
 */
+ (void)configureRequestFailure:(CHHTTPRequestFailure)failure withTask:(NSURLSessionDataTask *)task error:(NSError *)error
{
    [CHHTTPHelper configureRequestFailure:failure withTask:task error:error responseObject:nil];
}

/**
 *  根据返回数据, 配置请求失败回调(无error)
 */
+ (void)configureRequestFailure:(CHHTTPRequestFailure)failure withTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    [CHHTTPHelper configureRequestFailure:failure withTask:task error:nil responseObject:responseObject];
}

/**
 *  根据返回数据, 配置请求失败回调
 */
+ (void)configureRequestFailure:(CHHTTPRequestFailure)failure withTask:(NSURLSessionDataTask *)task error:(NSError *)error responseObject:(id)responseObject
{
    if (!responseObject)
    {
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error exCode:DEFAULT_EX_CODE exMsg:DEFAULT_EX_MSG];
        return;
    }
    
    NSString *exCode = !responseObject[@"exCode"]?DEFAULT_EX_CODE:responseObject[@"exCode"];
    NSString *exMsg = !responseObject[@"exMsg"]?DEFAULT_EX_MSG:responseObject[@"exMsg"];
    
    [CHHTTPHelper configureRequestFailure:failure withTask:task error:error exCode:exCode exMsg:exMsg];
}

/**
 *  配置请求失败回调
 */
+ (void)configureRequestFailure:(CHHTTPRequestFailure)failure withTask:(NSURLSessionDataTask *)task error:(NSError *)error exCode:(NSString *)exCode exMsg:(NSString *)exMsg
{
    !failure?:failure(task, error, exCode, exMsg);
}

/**
 *  配置请求完成回调
 */
+ (void)configureRequestAllCompletion:(CHHTTPRequestAllCompletion)completion
{
    !completion?:completion();
}

#pragma mark - Request Method
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion
{
    return [self.manager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [CHHTTPHelper configureRequestSuccess:success requestFailure:failure withTask:task responseObject:responseObject];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
    }];
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion
{
    return [self.manager HEAD:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
        
        [CHHTTPHelper configureRequestSuccess:success requestFailure:failure withTask:task responseObject:nil];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
    }];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion
{
    return [self.manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [CHHTTPHelper configureRequestSuccess:success requestFailure:failure withTask:task responseObject:responseObject];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
    }];
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion
{
    return [self.manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [CHHTTPHelper configureRequestSuccess:success requestFailure:failure withTask:task responseObject:responseObject];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
    }];
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion
{
    return [self.manager PATCH:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [CHHTTPHelper configureRequestSuccess:success requestFailure:failure withTask:task responseObject:responseObject];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
    }];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(CHHTTPRequestSuccess)success failure:(CHHTTPRequestFailure)failure allCompletion:(CHHTTPRequestAllCompletion)allCompletion
{
    return [self.manager DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [CHHTTPHelper configureRequestSuccess:success requestFailure:failure withTask:task responseObject:responseObject];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [CHHTTPHelper configureRequestFailure:failure withTask:task error:error];
        
        [CHHTTPHelper configureRequestAllCompletion:allCompletion];
    }];
}

@end
