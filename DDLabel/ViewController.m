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
    label1.text = @"http://123jyfkugicom家哈四大活动啊活动啊都,i 啊是崔从此你;http://hh11111hhh.com你;http://hhh3333hhcom你;http://hh4444hhh.com你;http://hhh5555hh.com你;http://hhh66666hh.comkhfishfosfspfjs你了;http://hh77777hhh.comdwefwefefegfsojfs 开始都是废话‘了佛教;http://hh88888hhh.com你了;http://hh9999hhh.com";
    label1.delegate = self;
    [self.view addSubview:label1];
    
    DDLabel *label2 = [[DDLabel alloc] initWithFrame:CGRectMake(0, 310, 375, 300)];
    label2.text = @"http://1444423.com家哈四大活动啊活动啊都,i 啊是崔从此你;http://hh11111hhh.com你;http://hhh3333hh.com你;http://hh4444hhh.com你;http://hhh5555hh.com你;http://hhh66666hh.comkhfishfosfspfjs你了;http://hh77777hhh.comdwefwefefegfsojfs 开始都是废话‘了佛教;http://hh88888hhh.com你了;http://hh9999hhh.com";
    label2.delegate = self;
    [self.view addSubview:label2];

}

- (void)label:(DDLabel *)label didSelectedAtText:(NSString *)text {
    NSLog(@"%@---%@", label, text);
}

@end
