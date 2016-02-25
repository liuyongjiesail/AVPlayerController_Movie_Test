//
//  PlayerViewController.m
//  SelfMovieTest
//
//  Created by 刘永杰 on 15/12/30.
//  Copyright © 2015年 刘永杰. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController ()<AVPlayerViewControllerDelegate>


@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14468618701471.mp4"]];
//    
//    self.showsPlaybackControls = YES;
//    
//    [self.player play];
//    
//    self.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
