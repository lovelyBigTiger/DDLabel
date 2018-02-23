//
//  DDLabel.m
//  DDLabel
//
//  Created by wyl on 2018/2/22.
//  Copyright © 2018年 wyl. All rights reserved.
//

#import "DDLabel.h"

@interface DDLabel()

// 符合条的链接数组
@property (nonatomic, strong) NSMutableArray *linkRangeStrings;

// 当前选择的数据
@property (nonatomic, assign) NSRange selectedRange;

// 用来存储文本属性信息
@property (nonatomic, strong) NSTextStorage *textStorage;

// 管理 NSTextStorage, 对文字内容进行排版布局
@property (nonatomic, strong) NSLayoutManager *layoutManager;

// 定义一个矩形区域, 用于存放已经排版好的文字
@property (nonatomic, strong) NSTextContainer *textContainer;

@end

@implementation DDLabel

#pragma mark - 重写 set 方法

- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateTextStorage];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self updateTextStorage];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updateTextStorage];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self updateTextStorage];
}

#pragma mark - 私有方法
- (void)updateTextStorage {
    if (self.attributedText == nil) {
        return;
    }

    NSMutableAttributedString *attributedM = [self addLineBreak:self.attributedText];
    [self regexLinkRanges:attributedM];
    [self addLinkAttribute:attributedM];
    
    [_textStorage setAttributedString:attributedM];
    
    [self setNeedsDisplay];
}

- (void)addLinkAttribute:(NSMutableAttributedString *)attrStringM {
    
    if (_patterns.count == 0) {
        return;
    }
    
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[attrStringM attributesAtIndex:0 effectiveRange:&range]];
    
    attributes[NSFontAttributeName] = self.font;
    attributes[NSForegroundColorAttributeName] = self.textColor;
    [attrStringM addAttributes:attributes range:range];
    attributes[NSForegroundColorAttributeName] = self.linkTextColor;
    
    for (NSString *rangeStr in _linkRangeStrings) {
        NSRange range = NSRangeFromString(rangeStr);
        
        [attrStringM addAttributes:attributes range:range];
    }
    
}

- (void)regexLinkRanges:(NSAttributedString *)attrString {
    if (_patterns.count == 0) {
        return;
    }
    
    [_linkRangeStrings removeAllObjects];
    
    NSRange regexRange = NSMakeRange(0, attrString.string.length);
    
    for (NSString *pattern in _patterns) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionDotMatchesLineSeparators
                                                                                 error:&error];
        if (error == nil) {
            NSArray *results = [regex matchesInString:attrString.string
                                              options:NSMatchingReportProgress
                                                range:regexRange];
            
            for (NSTextCheckingResult *r in results) {
                NSString *rangeStr = NSStringFromRange(r.range);
                [_linkRangeStrings addObject:rangeStr];
            }
        }
    }
}

- (NSMutableAttributedString *)addLineBreak:(NSAttributedString *)attrString {
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
    
    if (attributeStr.length == 0) {
        return attributeStr;
    }
    
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[attributeStr attributesAtIndex:0 effectiveRange:&range]];
    
    NSMutableParagraphStyle *oldparagraphStyle = attributes[NSParagraphStyleAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    if (oldparagraphStyle) {
        [paragraphStyle setParagraphStyle:oldparagraphStyle];
    }
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    [attributeStr setAttributes:attributes range:range];
    
    return attributeStr;
}

#pragma mark - draw text

//// 记住不要 调用 super 的方法
- (void)drawTextInRect:(CGRect)rect {
    
    NSRange range = [self dd_glyphsRange];
    CGPoint offset = [self dd_glyphsOffset:range];
    
    [_layoutManager drawBackgroundForGlyphRange:range atPoint:offset];
    [_layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}

- (NSRange )dd_glyphsRange {
    return NSMakeRange(0, _textStorage.length);
}

- (CGPoint )dd_glyphsOffset:(NSRange)range {
    CGRect rect = [_layoutManager boundingRectForGlyphRange:range inTextContainer:_textContainer];
    CGFloat height = (self.bounds.size.height - rect.size.height) * 0.5;
    
    return CGPointMake(0, height);
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    self.selectedRange = [self linkRangeAtLocation:location];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    NSRange range = [self linkRangeAtLocation:location];
    
    if (range.length != 0 || range.location != 0) {
        if (!(range.location == self.selectedRange.location && range.length == self.selectedRange.length)) {
//            [self modifySelectedAttribute:NO];
            self.selectedRange = range;
//            [self modifySelectedAttribute:YES];
        }
    }else {
//        [self modifySelectedAttribute:NO];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_selectedRange.length != 0 || _selectedRange.location != 0) {
        NSString *text = [_textStorage.string substringWithRange:_selectedRange];
        
        if ([self.delegate respondsToSelector:@selector(label:didSelectedAtText:)]) {
            [_delegate label:self didSelectedAtText:text];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

// 点击链接的位置
- (NSRange)linkRangeAtLocation:(CGPoint)location {
    
    if (_textStorage.length == 0) {
        return NSMakeRange(0, 0);
    }
    
    /*
     * 防止最后一个字符是被规则选择的字符,点击这个label 下面空白处时, 依旧会触发事件.
     */
    CGFloat fractionOfDistance = [_layoutManager fractionOfDistanceThroughGlyphForPoint:location inTextContainer:_textContainer];
    if (fractionOfDistance == 1) {
        return NSMakeRange(0, 0);
    }
    
    NSInteger index = [_layoutManager glyphIndexForPoint:location inTextContainer:_textContainer];
    
    for (NSString *rangeStr in _linkRangeStrings) {
        
        NSRange range = NSRangeFromString(rangeStr);
        
        if (index >= range.location && index < range.location + range.length) {
            return range;
        }
    }
    
    return NSMakeRange(0, 0);
}

#pragma mark - 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepareLabel];
    }
    return self;
}

- (void)prepareLabel {
    // 初始化数据
    _linkTextColor = [UIColor blueColor];
    _linkRangeStrings = [NSMutableArray array];
    _selectedRange = NSMakeRange(0, 0);
    _layoutManager = [[NSLayoutManager alloc] init];
    _textStorage   = [[NSTextStorage alloc] init];
    _textContainer = [[NSTextContainer alloc] init];
    
    [_textStorage addLayoutManager:_layoutManager];
    [_layoutManager addTextContainer:_textContainer];
    
    _textContainer.lineFragmentPadding = 0.0;
    
    _patterns = @[@"((http|ftp|https)://)[a-zA-Z0-9/\\.]*"]; // "((http|ftp|https)://)[a-zA-Z0-9/\\.]*"
    
    self.numberOfLines = 0;
    [self setUserInteractionEnabled:YES];
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textContainer.size = self.bounds.size;
}

@end
