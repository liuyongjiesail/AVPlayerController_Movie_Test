//
//  ViewController.m
//  SelfMovieTest
//
//  Created by 刘永杰 on 15/12/30.
//  Copyright © 2015年 刘永杰. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"

typedef NS_ENUM(NSInteger, PanDirection){
    
    PanDirectionHorizontalMoved,    //水平方向移动
    PanDirectionVerticalMoved       //垂直方向移动
};

@interface ViewController ()<AVPlayerViewControllerDelegate>
{
    PanDirection panDirection;
}

//视频展示View
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
// 播放/暂停按钮
@property(weak, nonatomic) IBOutlet UIButton *playButtonAction;
//开始时间
@property(weak, nonatomic) IBOutlet UILabel *startTime;
//结束时间
@property(weak, nonatomic) IBOutlet UILabel *endTime;
//全屏按钮
@property(weak, nonatomic) IBOutlet UIButton *fullScreenButton;
//进度条
@property(weak, nonatomic) IBOutlet UISlider *sliderButton;
//视频控制View
@property(weak, nonatomic) IBOutlet UIView *controllView;
//视频播放控件
@property(strong, nonatomic) AVPlayerViewController *playerVC;
//视频播放项目
@property(strong, nonatomic) AVPlayerItem *playerItem;
//计时器
@property(strong, nonatomic) NSTimer *timer;
//视频缓冲进度条
@property(weak, nonatomic) IBOutlet UIProgressView *progressView;
//获取系统音量条
@property(strong, nonatomic) UISlider *systemSlider;
//系统音量组件
@property(strong, nonatomic) MPVolumeView *systemVolume;
//自己的音量条
@property(strong, nonatomic) UISlider *volumeSlider;
//放置音量slider的view
@property (weak, nonatomic) IBOutlet UIView *volumeBackView;



@end

@implementation ViewController

- (void)dealloc
{
    [self.timer invalidate];   //永久关闭定时器
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //接收到程序进入后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:@"enterBackground" object:nil];
    //程序返回进入活跃状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"becomeActive" object:nil];
    
    /*
    //判断目前网络状态
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                
                NSLog(@"目前网络为WIFI");
                self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14468618701471.mp4"]];
                
                [self playAction:self.playButtonAction];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"目前是4G网络状态，确定播放？" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *trueAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14468618701471.mp4"]];
                    
                }];
                
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertController addAction:trueAction];
                [alertController addAction:cancleAction];
                
                [self presentViewController:alertController animated:YES completion:^{
                    
                }];
                
                break;
            }
                
                
            default:
                break;
        }
        
    }];
    
    [manager startMonitoring];
     
     */
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.playerVC = [[AVPlayerViewController alloc] init];
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14468618701471.mp4"]];

    self.playerVC.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerVC.delegate = self;
    //移除系统控件
    self.playerVC.showsPlaybackControls = NO;
    self.playerVC.view.frame = self.imageView.frame;
    [self addChildViewController:self.playerVC];
    [self.imageView addSubview:self.playerVC.view];
    self.playerVC.view.hidden = YES;
    
    NSLog(@"zhixing");
    

    [self setupAction];
    
    //通知中心监听视频加载是否完成
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
//    self.playerVC.player addObserver:self forKeyPath:<#(nonnull NSString *)#> options: context:<#(nullable void *)#>
    
    //初始化定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
    // Do any additional setup after loading the view, typically from a nib.
}
//隐藏状态栏
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

#pragma mark -- 添加视频播放控件
- (void)setupAction
{
    self.controllView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    
    [self.sliderButton setThumbImage:[UIImage imageNamed:@"radio_bt_choose"] forState:UIControlStateNormal];
    
    [self.playButtonAction setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
    [self.playButtonAction setBackgroundImage:[UIImage imageNamed:@"iconfont-zanting"] forState:UIControlStateSelected];
    
    [self.playButtonAction addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    //视频进度置0
    [self.sliderButton setValue:0.0 animated:NO];
    self.sliderButton.userInteractionEnabled = NO;
    
    //视频缓冲进度置0
    self.progressView.progressViewStyle = UIProgressViewStyleDefault;
    self.progressView.progressTintColor = [UIColor redColor];
    self.progressView.progress = 0.0;
    
    //添加轻拍手势，隐藏或显示控件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    //添加平移手势，左右移动快进快退，上下移动调节音量
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:pan];
    
    //自定义音量条
    
    self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(-80, 100, self.view.frame.size.height / 4, 40)];
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"radio_bt_choose"] forState:UIControlStateNormal];
    self.volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    [self.volumeSlider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
    [self.volumeBackView addSubview:self.volumeSlider];
    
    //获取系统的音量条
    self.systemVolume = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 50, 100, 50)];
    for (UIView *view in self.systemVolume.subviews) {
        
        if ([view isKindOfClass:[UISlider class]]) {
            
            self.systemSlider = (UISlider *)view;
        }
    }
}

#pragma mark -- 程序进入后台的通知
- (void)enterBackground
{
    self.playButtonAction.selected = NO;
}
#pragma mark -- 程序进入活跃状态的通知
- (void)becomeActive
{
    [self playAction:self.playButtonAction];
}

#pragma mark -- 通过定时器事件控制视频播放进度
- (void)timerAction
{
#warning 这里必须加上这层判断，否则会崩溃
    if (self.playerVC.player.status == AVPlayerItemStatusReadyToPlay) {
        
        NSLog(@"定时器在运行");
        CMTime time = [self.playerVC.player currentTime];
        
        NSInteger curtime = time.value / time.timescale;
        
        NSInteger curMin = curtime / 60;
        NSInteger curSec = curtime % 60;
        
        if (curMin > 60) {
            NSInteger curHours = curMin / 60;
            NSInteger curMin2 = curMin % 60;
            self.startTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)curHours, (long)curMin2, (long)curSec];
        } else {
            self.startTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)curMin, (long)curSec];
        }
        
        //利用总时长计算slider的每次移动距离 * 目前的时间 就是process
        NSInteger total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        [self.sliderButton setValue: (1.0 / total) * curtime animated:YES];
        
        //当目前的播放时间与视频总时长相等时，视频播放完毕
        if (total == curtime) {
            
            NSLog(@"视频播放完成");
            self.playButtonAction.selected = NO;
            //slider回归零点位置
            [self.sliderButton setValue:0.0 animated:NO];
            [self.timer fireDate];
            //视频回到零点位置，等待重播
            CMTime CTtime = CMTimeMake(0, 1);
            [self.playerVC.player seekToTime:CTtime completionHandler:^(BOOL finished) {
                
                [self.timer setFireDate:[NSDate distantFuture]];   //视频播放完成后关闭定时器
                [self.playerVC.player pause];
                self.playerVC.view.hidden = YES;
                self.controllView.hidden = NO;
                self.volumeBackView.hidden = NO;
            }];
            
        }

    }
    
}

//视频加载完成后，计算视频的总时长
- (void)playerReady
{
    if (self.playerVC.player.status == AVPlayerItemStatusReadyToPlay) {
        
        NSInteger total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        
        NSInteger durMin = total / 60;
        
        NSInteger durSec = total % 60;
        
        if (durMin > 60) {
            
            NSInteger durHours = durMin / 60;
            NSInteger durMin2 = durMin % 60;
            
            self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)durHours, (long)durMin2, (long)durSec];
        } else {
            
            self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)durMin, (long)durSec];
        }
        
    }
    
}

#pragma mark --- 手势事件
//轻拍事件
- (void)tapAction
{
    [UIApplication sharedApplication].statusBarHidden = ![UIApplication sharedApplication].statusBarHidden;
    
    [self.controllView setHidden: !self.controllView.hidden ? YES : NO];
    self.volumeBackView.hidden = !self.volumeBackView.hidden;
    
    //8秒后隐藏控件
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.controllView.hidden = YES;
        self.volumeBackView.hidden = YES;
        
    });
    
}

//平移手势
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    
    CGPoint velocityPoint = [pan velocityInView:self.view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {  //移动开始
            NSLog(@"开始移动");
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            if (x > y) {
                panDirection = PanDirectionHorizontalMoved;
                self.controllView.hidden = NO;
                [self.playerVC.player pause];
            }
            if (x < y) {
                panDirection = PanDirectionVerticalMoved;
                self.volumeBackView.hidden = NO;

            }
            
            break;

        }
        case UIGestureRecognizerStateChanged: {  //正在移动
            NSLog(@"正在移动");
            switch (panDirection) {
                case PanDirectionHorizontalMoved: {   //水平移动
                    NSLog(@"x : %f", velocityPoint.x);
//                    NSLog(@"目前：%f", self.sliderButton.value);
                    self.sliderButton.value += velocityPoint.x / 10000;
                    [self sliderAction:self.sliderButton];
                    break;
                }
                case PanDirectionVerticalMoved: {    //垂直移动
                    NSLog(@"y : %f", velocityPoint.y);
                    self.systemSlider.value -= velocityPoint.y / 10000;
                    self.volumeSlider.value = self.systemSlider.value;
                    break;
                }
                    
                default:
                    break;
            }
            break;
            
        }
        case UIGestureRecognizerStateEnded: {   //移动结束
            NSLog(@"移动结束");
            switch (panDirection) {
                case PanDirectionHorizontalMoved: {   //水平移动
                    self.controllView.hidden = YES;
                    [self.playerVC.player play];
                    break;
                }
                case PanDirectionVerticalMoved: {    //垂直移动
                    self.volumeBackView.hidden = YES;

                    break;
                }
                default:
                    break;
            }
            break;
            
        }
        default:
            break;
    }
    
}

#pragma mark --- 视频调节音量、播放、暂停
//调节音频音量
- (void)changeVolume:(UISlider *)sender
{
    NSLog(@"拖动slider");
    [self.systemSlider setValue:self.volumeSlider.value animated:YES];
    
}

//播放视频
- (void)playAction:(UIButton *)sender
{
    [self.timer setFireDate:[NSDate distantPast]];   //开启定时器
    
    self.playerVC.view.hidden = NO;
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        self.sliderButton.userInteractionEnabled = YES;
        [self addChildViewController:self.playerVC];
        [self.imageView addSubview:self.playerVC.view];
        [self.playerVC.player play];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.controllView.hidden = YES;
            self.volumeBackView.hidden = YES;
        });
        
    } else {
        
        [self.playerVC.player pause];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

//暂停视频
- (void)pauseAction:(UIButton *)sender
{
    sender.selected = NO;

}
//
////将自动旋转关闭
//- (BOOL)shouldAutorotate{
//    
//    return NO;
//}

////支持的旋转方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//    
//}
////最优先显示屏幕方向
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    
//    return UIInterfaceOrientationLandscapeLeft;
//    
//}


//全屏播放
- (IBAction)fullScreenAction:(id)sender {
    
    /*
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    
    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.imageView.transform = CGAffineTransformMakeRotation(-M_PI / 2);

//    self.playerVC.view.transform = CGAffineTransformMakeRotation(-M_PI);
//    self.playerVC.view.frame = CGRectMake(0, -120, self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"%f", self.view.bounds.size.height);
    self.controllView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    self.controllView.frame = CGRectMake(200, 40, [UIScreen mainScreen].bounds.size.width, 40);
     */
    
}


//快进快退播放
- (IBAction)sliderAction:(id)sender {
    
    NSInteger total = self.playerItem.duration.value / self.playerItem.duration.timescale;
    [self.playerVC.player pause];
    
    NSInteger currentTime = total * self.sliderButton.value;
    
    CMTime currentCTtime = CMTimeMake(currentTime, 1);
    
    [self.playerVC.player seekToTime:currentCTtime completionHandler:^(BOOL finished) {
        
        [self.playerVC.player play];
    }];
}

//视频缓冲观察方法  --- 这个方法会一直走，直到视频缓存完成
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"正在缓冲视频文件");
    //开始缓冲得时候获取目前的系统音量并赋给自定义的音量控制slider
    self.volumeSlider.value = self.systemSlider.value;
    
    //总时长
    NSInteger total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    //视频缓冲进度计算
    NSArray *loadedTimeRanges = self.playerVC.player.currentItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; //获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    
    //设定缓冲进度条展示
    [self.progressView setProgress:result / total animated:YES];
    
    //计算出视频总时长并赋值
    [self playerReady];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    PlayerViewController *playerVC = [[PlayerViewController alloc] init];
//    
//    [self showViewController:playerVC sender:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
