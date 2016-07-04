//
//  ViewController.m
//  CHHTTPHelper
//
//  Created by colin on 16/7/4.
//  Copyright © 2016年 CHwang. All rights reserved.
//

#import "ViewController.h"

#import "CHHTTPHelper.h"
#import "APIConstants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self testRequest];
}

- (void)testRequest
{
    // A test. You should change URL and parameters.
    NSString *URLString = [CHHTTPHelper URLWithModule:MODULE_USER APIPath:API_REGISTER_PATH];
    
    NSLog(@"URL:%@", URLString);
    
    NSDictionary *parameters = @{@"test":@"1"};
    
    [[CHHTTPHelper defaultHTTPHelper] GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"Success--%@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSString *exCode, NSString *exMsg) {
        
        NSLog(@"Failure--exCode:%@, exMsg:%@, error:%@", exCode, exMsg, error);
    } allCompletion:^{
        
        NSLog(@"Completion!");
    }];
}

@end
