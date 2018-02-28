//
//  ServerManager.m
//  netronixdemo
//
//  Created by Oleg Sitovs on 26/02/2018.
//  Copyright © 2018 Oleg Sitovs. All rights reserved.
//

#import "ServerManager.h"
#import "Reachability/Reachability.h"
#import "AFHTTPSessionManager.h"

NSString *const kBaseUrl = @"http://192.168.0.115:3000";
NSString *const kGetProjectData = @"/api/v1/register";

static ServerManager *defaultManager = nil;

@implementation ServerManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (defaultManager == nil) {
            defaultManager = [[ServerManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
        }
    });
    return defaultManager;
}

+ (BOOL)isReachable {
    NetworkStatus internetStatus = [[self.class reachability] currentReachabilityStatus];
    return internetStatus != NotReachable;
}

+ (NSError*)createNoInternetError {
    return [NSError errorWithDomain:ErrorDomainNoInternet code:4004 userInfo:nil];
}

- (void)getWithPath:(NSString *)path
         parameters:(id)parameters
            success:(onServiceSuccess)successBlock
            failure:(onServiceFailure)failureBlock {
    if (![self.class isReachable]) {
        if (failureBlock) {
            NSError *noInternetError = [ServerManager createNoInternetError];
            failureBlock(nil, noInternetError, nil);
        }
        return;
    }
    
    [self GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DebugLog(@"**** SUCCESS ****");
        DebugLog(@"%@", responseObject);
        
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(task, error, [self.class responseObjectFromError:error]);
        }
    }];
    
}

#pragma mark - Private API

+ (Reachability *)reachability {
    static Reachability *reachabilityInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reachabilityInstance = [Reachability reachabilityForInternetConnection];
    });
    return reachabilityInstance;
}

+ (id)responseObjectFromError:(NSError *)error {
    NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (data.length > 0) {
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
        
        if ([jsonDict[@"error"] isKindOfClass:[NSArray class]]) {
            NSArray *array = [NSArray arrayWithArray:jsonDict[@"error"]];
            NSString *result = [array componentsJoinedByString:@", "];
            return result;
        } else if ([jsonDict[@"error"] isKindOfClass:[NSString class]]) {
            NSString *result = jsonDict[@"error"];
            return result;
        }
    }
    return nil;
}


- (instancetype)initWithBaseURL:(nullable NSURL *)url {
    
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json", @"text/html"]]];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
    }
    
    return self;
}


@end
