//
//  ViewController.m
//  instagram
//
//  Created by ShihKuo-Hsun on 2015/5/1.
//  Copyright (c) 2015年 FT. All rights reserved.
//

#import "ViewController.h"

#import "FTInstagram.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[FTInstagram shareInstance] loginWithScope:@[@"basic",@"comments",@"likes",@"relationships"] Completion:^(BOOL success, NSString *errorReason) {
        if (success) {
            [self loadWithAPI];
        }else{
            NSLog(@"%@",errorReason);
        }
    }];
}

-(void)loadWithAPI{
    
    [[FTInstagram shareInstance] userInformationWithID:kSelf comepletion:^(NSDictionary *response) {
        NSLog(@"%@",response);
        NSLog(@"==================================================");
        
        [[FTInstagram shareInstance] userRecentMediaWithID:kSelf comepletion:^(NSDictionary *response) {
            NSLog(@"%@",response);
        } failure:^(NSError *error, NSString *message) {
            NSLog(@"%@",message);
        }];
    } failure:^(NSError *error, NSString *message) {
        NSLog(@"%@",message);
    }];
}

@end
