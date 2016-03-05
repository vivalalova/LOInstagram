//
//  ViewController.m
//  instagram
//
//  Created by ShihKuo-Hsun on 2015/5/1.
//  Copyright (c) 2015年 FT. All rights reserved.
//

#import "ViewController.h"

#import "LOInstagram.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[LOInstagram shareInstance] loginWithScope:@[@"basic",@"comments",@"likes",@"relationships"] Completion:^(BOOL success, NSString *errorReason) {
        if (success) {
            [self loadWithAPI];
        }else{
            NSLog(@"%@",errorReason);
        }
    }];
}

-(void)loadWithAPI{
    
    [[LOInstagram shareInstance] userInformationWithID:kSelf comepletion:^(NSDictionary *response) {
        NSLog(@"%@",response);
        NSLog(@"==================================================");
        
        [[LOInstagram shareInstance] userRecentMediaWithID:kSelf comepletion:^(NSDictionary *response) {
            NSLog(@"%@",response);
        } failure:^(NSError *error, NSString *message) {
            NSLog(@"%@",message);
        }];
    } failure:^(NSError *error, NSString *message) {
        NSLog(@"%@",message);
    }];
}

@end
