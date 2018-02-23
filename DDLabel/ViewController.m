//
//  ViewController.m
//  DDLabel
//
//  Created by wyl on 2018/2/22.
//  Copyright © 2018年 wyl. All rights reserved.
//

#import "ViewController.h"
#import "DDLabel.h"

@interface ViewController ()<DDLabelDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DDLabel *label1 = [[DDLabel alloc] initWithFrame:CGRectMake(0, 100, 375, 300)];
    label1.text = @"http://baidu.com哈哈哈哈哈http://hh9999hhh.com";
    label1.delegate = self;
    [self.view addSubview:label1];
}

- (void)label:(DDLabel *)label didSelectedAtText:(NSString *)text {
    NSLog(@"%@---%@", label, text);
}

@end
