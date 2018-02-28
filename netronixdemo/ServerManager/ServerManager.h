//
//  ServerManager.h
//  netronixdemo
//
//  Created by Oleg Sitovs on 26/02/2018.
//  Copyright © 2018 Oleg Sitovs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

FOUNDATION_EXPORT NSString *const kBaseUrl;
FOUNDATION_EXPORT NSString *const kGetProjectData;

static NSString * const ErrorDomainNoInternet = @"ErrorDomainNoInternet";

typedef void (^onServiceSuccess)(id data);
typedef void (^onServiceFailure)(NSURLSessionDataTask *task, NSError *error, id responseObject);

@interface ServerManager : AFHTTPSessionManager

+ (instancetype)defaultManager;
+ (BOOL)isReachable;

- (void)getWithPath:(NSString *)path
         parameters:(id)parameters
            success:(onServiceSuccess)successBlock
            failure:(onServiceFailure)failureBlock;

@end
