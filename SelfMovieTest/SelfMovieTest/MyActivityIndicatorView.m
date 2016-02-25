//
//  MyActivityIndicatorView.m
//  SelfMovieTest
//
//  Created by 刘永杰 on 15/12/30.
//  Copyright © 2015年 刘永杰. All rights reserved.
//

#import "MyActivityIndicatorView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@implementation MyActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self p_setupViews];
        
    }
    return self;
}

- (void)p_setupViews
{
    self.frame = CGRectMake(kWidth/2 - 50, kHeight/2-50, 100, 100);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10;
    
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 80, 40)];
    label.text = @"loading...";
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
