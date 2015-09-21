//
//  LOInstagramKitHelper.m
//  Pamperologist
//
//  Created by ShihKuo-Hsun on 2015/4/28.
//  Copyright (c) 2015年 Pamperologist. All rights reserved.
//

#import "LOInstagram.h"
#import <AFNetworking.h>

LOInstagram *instagramHelper;

typedef void (^LoginCompleteHandler)(BOOL success, NSString *errorReason);

typedef enum {
    igCRUDMethod_GET,
    igCRUDMethod_POST,
    igCRUDMethod_DELETE,
    igCRUDMethod_PATCH,
    igCRUDMethod_PUT
}igCRUDMethod;

#define kInstagramBaseURL @"https://instagram.com"
#define kAPIBaseURL @"https://api.instagram.com/v1"
#define kKeyOfTokenWithUserDefault @"keyOfTokenWithUserDefault"
#define kToken @"token"

#ifdef DEBUG
#define NSLog(s, ...) NSLog(@"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ## __VA_ARGS__])
#else
#define NSLog(s, ...)
#endif

@interface LOInstagram () {
    LoginCompleteHandler loginCompleteHandler;
    
    NSString *nextPageUrl;
}

//app id on instagram
@property (strong, nonatomic) NSString *clientID;
//@property (strong, nonatomic) NSString *clientSecret;
@property (strong, nonatomic) NSString *redirectUri;

@property (strong, nonatomic) NSString *token;

//info.plist url types
@property (strong, nonatomic) NSArray *infoPlistUrlType;

@end

@implementation LOInstagram

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - public
+ (instancetype)shareInstance {
    if (!instagramHelper) {
        instagramHelper = [[LOInstagram alloc] init];
    }
    return instagramHelper;
}

- (void)loginWithScope:(NSArray *)scopes Completion:(void (^)(BOOL success, NSString *errorReason))complete {
    NSString *authURL = [NSString stringWithFormat:@"%@/oauth/authorize/", kInstagramBaseURL];
    
    //array convert to string = value1+value2+value3
    NSString *scopesString = [[scopes valueForKey:@"description"] componentsJoinedByString:@"+"];
    NSString *url = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&scope=%@&response_type=%@", authURL, self.clientID, self.redirectUri, scopesString, kToken];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    //指過去  然後等呼叫;
    loginCompleteHandler = complete;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // user denied example  :
    // "ig75655b039682459099fcf30cfad1990f:?error_reason=user_denied&error=access_denied&error_description=The+user+denied+your+request.";
    
    NSLog(@"%@",application);
    NSLog(@"%@",url);
    NSLog(@"%@",sourceApplication);
    NSLog(@"%@",self.redirectUri);
    
    NSString *scheme = [self.redirectUri stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    if ([[url scheme] isEqualToString:scheme]) {
        // parse url 'xxx=ooo&' to dictionary
        NSString *parametersString = [[url resourceSpecifier] stringByReplacingOccurrencesOfString:@"?" withString:@""];
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        NSMutableDictionary *parametersStringDictionary = [[NSMutableDictionary alloc] init];
        
        
        NSLog(@"%@",parametersStringDictionary);
        
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [parametersStringDictionary setObject:value forKey:key];
        }
        
        if (parametersStringDictionary[@"#access_token"]) {
            self.token = parametersStringDictionary[@"#access_token"];
            
            NSLog(@"NICE!!!  token :%@",self.token);
            loginCompleteHandler(YES, nil);
            return YES;
        }
        
        if (parametersStringDictionary[@"error"]) {
            NSLog(@"ERROR!!!");
            loginCompleteHandler(NO, parametersStringDictionary[@"error"]);
            return YES;
        }
    }
    
    return NO;
}

- (void)userInformationWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure {
    //新的開始  清掉next page;
    nextPageUrl = nil;
    
    //https://api.instagram.com/v1/users/{user-id}
    NSString *url = [NSString stringWithFormat:@"%@/users/", kAPIBaseURL];
    NSLog(@"%@",url);
    
    [self connectWithHTTPMethod:igCRUDMethod_GET URLString:url IDString:userID parameters:@{ @"access_token" : self.token } alertWithError:NO success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"success");
        complete(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, NSString *message) {
        NSLog(@"fail");
        failure(error, message);
    }];
}

- (void)userRecentMediaWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure {
    //https://api.instagram.com/v1/users/{user-id}/media/recent
    
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/media/recent", kAPIBaseURL, userID];
    
    [self connectWithHTTPMethod:igCRUDMethod_GET URLString:url IDString:nil parameters:@{ @"access_token" : self.token } alertWithError:NO success:^(AFHTTPRequestOperation *operation, id response) {
        complete(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, NSString *message) {
        failure(error, message);
    }];
}

- (void)userRecentMediaWithNextPageComepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure {
    if (!nextPageUrl) {
        failure([[NSError alloc] init], @"there is no next page");
    }
    
    [self connectWithHTTPMethod:igCRUDMethod_GET URLString:nextPageUrl IDString:nil parameters:nil alertWithError:NO success:^(AFHTTPRequestOperation *operation, id response) {
        complete(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, NSString *message) {
        failure(error, message);
    }];
}

#pragma mark --0504新增follow/followedBy
- (void)userFolowsWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure {
    //https://api.instagram.com/v1/users/{user-id}/follows?access_token=ACCESS-TOKEN
    
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/follows?access_token=%@", kAPIBaseURL, userID, kToken];
    
    [self connectWithHTTPMethod:igCRUDMethod_GET URLString:url IDString:nil parameters:@{ @"access_token" : self.token } alertWithError:NO success:^(AFHTTPRequestOperation *operation, id response) {
        complete(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, NSString *message) {
        failure(error, message);
    }];
}

- (void)userFolowedByWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure {
    //https://api.instagram.com/v1/users/{user-id}/followed-by?access_token=ACCESS-TOKEN
    
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/followed-by?access_token=%@", kAPIBaseURL, userID, kToken];
    
    [self connectWithHTTPMethod:igCRUDMethod_GET URLString:url IDString:nil parameters:@{ @"access_token" : self.token } alertWithError:NO success:^(AFHTTPRequestOperation *operation, id response) {
        complete(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, NSString *message) {
        failure(error, message);
    }];
}

#pragma mark - private methods

- (void)connectWithHTTPMethod:(igCRUDMethod)method URLString:(NSString *)URLString IDString:(NSString *)IDString parameters:(id)parameters alertWithError:(BOOL)isAlert success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error, NSString *message))failure {
    if (IDString) {
        URLString = [NSString stringWithFormat:@"%@%@/", URLString, IDString];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (method == igCRUDMethod_GET) {
        [manager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (responseObject[@"pagination"][@"next_url"]) {
                    if (responseObject[@"pagination"][@"next_url"]) {
                        nextPageUrl = responseObject[@"pagination"][@"next_url"];
                    }
                }
                
                success(operation, responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMessage = [self parseErrorUserInfo:error];
                failure(operation, error, errMessage);
                
                if (isAlert) {
                    [self alertWithMessage:error.localizedDescription];
                }
            });
        }];
    } else if (method == igCRUDMethod_POST) {
        [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(operation, responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMessage = [self parseErrorUserInfo:error];
                failure(operation, error, errMessage);
                
                if (isAlert) {
                    [self alertWithMessage:error.localizedDescription];
                }
            });
        }];
    } else if (method == igCRUDMethod_PATCH) {
        [manager PATCH:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(operation, responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMessage = [self parseErrorUserInfo:error];
                failure(operation, error, errMessage);
                
                if (isAlert) {
                    [self alertWithMessage:error.localizedDescription];
                }
            });
        }];
    } else if (method == igCRUDMethod_PUT) {
        [manager PUT:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(operation, responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMessage = [self parseErrorUserInfo:error];
                failure(operation, error, errMessage);
                
                if (isAlert) {
                    [self alertWithMessage:error.localizedDescription];
                }
            });
        }];
    } else if (method == igCRUDMethod_DELETE) {
        [manager DELETE:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(operation, responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errMessage = [self parseErrorUserInfo:error];
                failure(operation, error, errMessage);
                
                if (isAlert) {
                    [self alertWithMessage:error.localizedDescription];
                }
            });
        }];
    }
}

- (void)alertWithMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (NSString *)parseErrorUserInfo:(NSError *)error {    
    return error.userInfo[@"NSLocalizedDescription"];
}

#pragma mark - getter and setter

+ (BOOL)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfTokenWithUserDefault] != nil ? YES : NO;
}

- (NSString *)token {
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfTokenWithUserDefault]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfTokenWithUserDefault];
}

- (void)setToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kKeyOfTokenWithUserDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// ex: 75655b039682459099fcf30cfad1990f
- (NSString *)clientID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InstagramAppID"];
}

// ex: ig75655b039682459099fcf30cfad1990f:
- (NSString *)redirectUri {
    for (NSDictionary *dict in self.infoPlistUrlType) {
        NSString *cfBundleURLSchemes = dict[@"CFBundleURLSchemes"][0];
        
        if ([cfBundleURLSchemes rangeOfString:self.clientID].location != NSNotFound) {
            return [NSString stringWithFormat:@"%@:", cfBundleURLSchemes];
        }
    }
    return nil;
}

- (NSArray *)infoPlistUrlType {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
}

@end
