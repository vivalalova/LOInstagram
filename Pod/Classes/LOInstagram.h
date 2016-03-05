//
//  LOInstagramKitHelper.h
//  Pamperologist
//
//  Created by ShihKuo-Hsun on 2015/4/28.
//  Copyright (c) 2015年 Pamperologist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kSelf @"self"
//to acess current user ,  @"self" instead @"user-id"
typedef NSString *instagramUserID;
@interface LOInstagram : NSObject

@property (strong, nonatomic) NSString *token;

+ (BOOL)accessToken;

+ (instancetype)shareInstance;

+ (void)logout;

- (void)loginWithScope:(NSArray *)scopes Completion:(void (^)(BOOL success, NSString *errorReason))complete;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)userInformationWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure;
- (void)userRecentMediaWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure;
- (void)userRecentMediaWithNextPageComepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure;

- (void)userFolowsWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure;
- (void)userFolowedByWithID:(instagramUserID)userID comepletion:(void (^)(NSDictionary *response))complete failure:(void (^)(NSError *error, NSString *message))failure;
@end
