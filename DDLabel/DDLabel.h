//
//  DDLabel.h
//  DDLabel
//
//  Created by wyl on 2018/2/22.
//  Copyright © 2018年 wyl. All rights reserved.
//
// 有一个 bug , 文本最后一个字符是符合规则的情况下,做不到精准点击,就是点击这个label后面的空白的

#import <UIKit/UIKit.h>
@class DDLabel;

@protocol DDLabelDelegate <NSObject>

@optional
- (void)label:(DDLabel *)label didSelectedAtText:(NSString *)text;

@end

@interface DDLabel : UILabel

@property (nonatomic, weak) id<DDLabelDelegate> delegate;

// 默认是 blue
@property (nonatomic, strong) UIColor *linkTextColor;

// 默认是超链接
@property (nonatomic, copy) NSArray *patterns;

@end
