//
//  JPAVPlayerView.m
//  PlayMovie
//
//  Created by Keep丶Dream on 2017/5/9.
//  Copyright © 2017年 dong. All rights reserved.
//

#import "JPAVPlayerView.h"

typedef NS_ENUM(NSInteger, TouchPlayerViewMode) {
    TouchPlayerViewModeNone, // 轻触
    TouchPlayerViewModeHorizontal, // 水平滑动
    TouchPlayerViewModeUnknow, // 未知
};


#pragma mark -常量
//top bottom view height
static const CGFloat baseViewH = 34.0f;
//play end time width
static const CGFloat timeW = 48.0f;
//play button rotation width height
static const CGFloat buttonWH = 14.0f;
//base margin
static const CGFloat baseMargin = 10.0f;

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

@interface JPAVPlayerView ()

/** playView */
@property(nonatomic,strong) UIView *playerView;
/** topView */
@property(nonatomic,strong) UIView *topView;
/** tip */
@property(nonatomic,strong) UILabel *tipTitle;
/** bottomView */
@property(nonatomic,strong) UIView *bottomView;
/** play/pause */
@property(nonatomic,strong) UIButton *playButton;
/** playtime */
@property(nonatomic,strong) UILabel *playTime;
/** endtime */
@property(nonatomic,strong) UILabel *endTime;
/** play progress */
@property(nonatomic,strong) UISlider *playProgress;
/** cache pregress */
@property(nonatomic,strong) UIProgressView *cacheProgress;
/** rotationButton */
@property(nonatomic,strong) UIButton *rotationButton;
/** AVPlayer 控制 播放/暂停 操作*/
@property(nonatomic,strong) AVPlayer *player;
/** AVPlayerItem 提供视频的信息  */
@property(nonatomic,strong) AVPlayerItem *playerItem;
/** AVPlayerLayer 显示视频界面 */
@property(nonatomic,strong) AVPlayerLayer *playerLayer;
/** transit 中转View */
@property(nonatomic,strong) UIView *transitPlayView;
@end

@implementation JPAVPlayerView
{
    BOOL _isSlidering; //是否在拖动进度条
    id  _playTimeObserver; //观察播放进度
    BOOL _isPlaying; //是否在播放中
    BOOL _isHiddenView;//上下View是否隐藏的状态
    TouchPlayerViewMode _touchMode;//触摸屏幕的结构体
}
+ (instancetype)getPlayerView {
    
    return [[[self class]alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenWidth*9.0/16)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self p_SetupUI];
    }
    return self;
}

#pragma mark -懒加载控件

- (UIView *)playerView{
    
    if (!_playerView) {
        
        _playerView = [[UIView alloc] initWithFrame:self.bounds];
        _playerView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_TouchPlayView)];
        _playerView.userInteractionEnabled = YES;
        [_playerView addGestureRecognizer:tap];
    }
    return _playerView;
}

- (UIView *)topView{
    
    if (!_topView) {
        
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor blackColor];
        _topView.alpha = 0.5;
    }
    return _topView;
}

- (UILabel *)tipTitle{
    
    if (!_tipTitle) {
        
        _tipTitle = [[UILabel alloc] init];
        _tipTitle.textAlignment = NSTextAlignmentCenter;
        _tipTitle.textColor = [UIColor whiteColor];
        _tipTitle.text = @"我是视频标题";
        _tipTitle.font = [UIFont systemFontOfSize:12];
    }
    return _tipTitle;
}


- (UIView *)bottomView{
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor blackColor];
        _bottomView.alpha = 0.5;
    }
    return _bottomView;
}

- (UIButton *)playButton{
    
    if (!_playButton) {
        
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"player_play_bottom_window"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(p_ClickPlayButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UILabel *)playTime{
    
    if (!_playTime) {
        
        _playTime = [[UILabel alloc] init];
        _playTime.textColor = [UIColor whiteColor];
        _playTime.textAlignment = NSTextAlignmentCenter;
        _playTime.text = @"00:00";
        _playTime.font = [UIFont systemFontOfSize:12];
    }
    return _playTime;
}

- (UILabel *)endTime{
    
    if (!_endTime) {
        
        _endTime = [[UILabel alloc] init];
        _endTime.textColor = [UIColor whiteColor];
        _endTime.textAlignment = NSTextAlignmentCenter;
        _endTime.text = @"90:00";
        _endTime.font = [UIFont systemFontOfSize:12];
    }
    return _endTime;
}

- (UISlider *)playProgress{
    
    if (!_playProgress) {
        
        _playProgress = [[UISlider alloc] init];
        [_playProgress setThumbImage:[UIImage imageNamed:@"icmpv_thumb_light"] forState:UIControlStateNormal];
        //已播放的颜色
        _playProgress.minimumTrackTintColor = [UIColor redColor];
        //未播放的颜色
        _playProgress.maximumTrackTintColor = [UIColor clearColor];
        //监听 开始拖动 拖动中国 拖动结束
        [_playProgress addTarget:self action:@selector(p_SliderBegin) forControlEvents:UIControlEventTouchDown];
        [_playProgress addTarget:self action:@selector(p_SliderUpdate) forControlEvents:UIControlEventValueChanged];
        [_playProgress addTarget:self action:@selector(p_SliderEnd) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playProgress;
}

- (UIProgressView *)cacheProgress{
    
    if (!_cacheProgress) {
        
        _cacheProgress = [[UIProgressView alloc] init];
        //整体进度条颜色 最底层
        _cacheProgress.trackTintColor = [UIColor whiteColor];
        //已缓存的颜色
        _cacheProgress.progressTintColor = [UIColor blueColor];
        _cacheProgress.progress = 0;
    }
    return _cacheProgress;
}

- (UIButton *)rotationButton{
    
    if (!_rotationButton) {
        
        _rotationButton = [[UIButton alloc] init];
        [_rotationButton setImage:[UIImage imageNamed:@"player_fullScreen_iphone"] forState:UIControlStateNormal];
        [_rotationButton setImage:[UIImage imageNamed:@"player_window_iphone"] forState:UIControlStateSelected];
        [_rotationButton addTarget:self action:@selector(p_ClickRotationButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotationButton;
}

- (AVPlayer *)player{
    
    if (!_player) {
        
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer{
    
    if (!_playerLayer) {
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
    }
    return _playerLayer;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.topView.frame = CGRectMake(0, 2*baseMargin, self.playerView.bounds.size.width, baseViewH);
    self.tipTitle.frame = CGRectMake(30, 0, self.playerView.bounds.size.width-60, baseViewH);
    self.bottomView.frame = CGRectMake(0, self.playerView.bounds.size.height-baseViewH, self.playerView.bounds.size.width, baseViewH);
    self.playButton.frame = CGRectMake(baseMargin, baseViewH/2-buttonWH/2, buttonWH, buttonWH);
    self.rotationButton.frame = CGRectMake(self.playerView.bounds.size.width-baseMargin-buttonWH, baseViewH/2-buttonWH/2, buttonWH, buttonWH);
    self.playTime.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), 0, timeW, baseViewH);
    self.endTime.frame = CGRectMake(CGRectGetMinX(self.rotationButton.frame)-timeW, 0, timeW, baseViewH);
    self.playProgress.frame = CGRectMake(CGRectGetMaxX(self.playTime.frame), 0, CGRectGetMinX(self.endTime.frame)-CGRectGetMaxX(self.playTime.frame), baseViewH);
    self.cacheProgress.frame = CGRectMake(CGRectGetMinX(self.playProgress.frame)+2, baseViewH/2-1, CGRectGetWidth(self.playProgress.frame)-2, 2);
    self.playerLayer.frame = self.playerView.bounds;
    
}

#pragma mark -设置UI

- (void)p_SetupUI {
    
    [self addSubview:self.playerView];
    [self.playerView.layer addSublayer:self.playerLayer];
    [self.playerView addSubview:self.topView];
    [self.topView addSubview:self.tipTitle];
    [self.playerView addSubview:self.bottomView];
    [self.bottomView addSubview:self.playButton];
    [self.bottomView addSubview:self.playTime];
    [self.bottomView addSubview:self.endTime];
    [self.bottomView addSubview:self.cacheProgress];
    [self.bottomView addSubview:self.playProgress];
    [self.bottomView addSubview:self.rotationButton];
}

#pragma mark -点击事件

- (void)p_ClickPlayButton {
    
    //播放或者暂停
    if (_isPlaying) {
        [self p_Pause];
    }else {
        [self p_Play];
    }
}

- (void)p_ClickRotationButton {
    
    self.rotationButton.selected = !self.rotationButton.selected;
    if (self.rotationButton.selected) {
        //大屏
        [self p_ChangeFullScreen];
    }else {
        //小屏
        [self p_ChangeSmallScreen];
    }

}

#pragma mark -切换大小屏

- (void)p_ChangeFullScreen {

    [UIView animateWithDuration:0.1 animations:^{
        self.playerView.frame = CGRectMake(0, 0, KScreenHeight, KScreenWidth);
//        self.playerView.center = CGPointMake(CGRectGetMidX(self.superview.frame), CGRectGetMidY(self.superview.frame));
//        self.playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.transitPlayView = self.playerView;
        [self.playerView removeFromSuperview];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.transitPlayView];
        [self layoutSubviews];
    }];

    [self forceOrientation:(UIInterfaceOrientationLandscapeRight)]; //切换为横屏

}

- (void)p_ChangeSmallScreen {
    
    [UIView animateWithDuration:0.1 animations:^{
        self.transitPlayView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
//        self.transitPlayView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
//        self.transitPlayView.transform = CGAffineTransformIdentity;
        self.playerView = self.transitPlayView;
        [self.transitPlayView removeFromSuperview];
        [self addSubview:self.playerView];
        [self layoutSubviews];
    }];

    [self forceOrientation:(UIInterfaceOrientationPortrait)]; // 切换为竖屏
}

- (void)forceOrientation:(UIInterfaceOrientation)orientation {
    // setOrientation: 私有方法强制横屏
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark -更换URL源

- (void)updatePlayWithNewUrl:(NSURL *)newUrl tipTitle:(NSString *)tipTitle{

    //设置标题
    self.tipTitle.text = tipTitle;
    self.cacheProgress.progress = 0;
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"status"];

    }
    self.playerItem = [AVPlayerItem playerItemWithURL:newUrl];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self p_AddObserverAndNotification];
}


#pragma mark -添加观察 通知

- (void)p_AddObserverAndNotification {
    
    //监测是否准备播放
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监测缓存状态
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //监测进度
    __weak typeof(self)WeakSelf = self;
    // 播放进度, 每秒执行30次， CMTime 为30分之一秒
    _playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (_touchMode != TouchPlayerViewModeHorizontal) {
            // 当前播放秒
            CGFloat currentPlayTime = (double)WeakSelf.playerItem.currentTime.value/ WeakSelf.playerItem.currentTime.timescale;
            // 更新slider, 如果正在滑动则不更新
            if (_isSlidering == NO) {
                [WeakSelf p_SetTimeAndSliderUpdateWith:currentPlayTime];
            }
        } else {
            return;
        }
    }];
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_PlayFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_EnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_EnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -KVO观察

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        //拿到status的状态 并判断是不是已经准备好
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        //准备播放
        if (status == AVPlayerStatusReadyToPlay) {
            //设置总时间
            CGFloat duration = CMTimeGetSeconds(playerItem.duration);
            [self p_SetMaxTimeAndSliderWith:duration];
            //开始播放
            [self p_Play];
            
        }else if (status == AVPlayerStatusFailed) {
            NSLog(@"视频加载失败");
        }else {
            NSLog(@"视频加载失败");
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        NSTimeInterval timeInterval = [self availableDurationRanges]; // 缓冲时间
        NSLog(@"已缓冲时间 %f",timeInterval);
        CGFloat totalDuration = CMTimeGetSeconds(_playerItem.duration); // 总时间
        NSLog(@"总时间  %f",totalDuration);
        [self.cacheProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

#pragma mark -播放/暂停

- (void)p_Play {
    
    self.playButton.selected = YES;
    _isPlaying = YES;
    [self.player play];
}

- (void)p_Pause {
    
    self.playButton.selected = NO;
    _isPlaying = NO;
    [self.player pause];
}

- (void)p_PlayFinished {
    
    [self.player seekToTime:kCMTimeZero];
    [self p_Pause];
}

- (void)p_EnterBackgroundNotification {
    
    [self p_Pause];
}

- (void)p_EnterForegroundNotification {
    
    if (!_isPlaying) {
        
        [self p_Play];
    }
}

#pragma mark -设置时间和进度

- (void)p_SetMaxTimeAndSliderWith:(CGFloat)duration {
    
    self.endTime.text = [self p_SecondsToMinute:duration];
    self.playProgress.maximumValue = duration;

}

- (void)p_SetTimeAndSliderUpdateWith:(CGFloat)currentTime {
    
    self.playTime.text = [self p_SecondsToMinute:currentTime];
    self.playProgress.value = currentTime;
}

// 已缓冲进度
- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges]; // 获取item的缓冲数组
    // discussion Returns an NSArray of NSValues containing CMTimeRanges
    
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}


#pragma mark -进度改变控制

- (void)p_SliderBegin {
    
    _isSlidering = YES;
    [self p_Pause];
}

- (void)p_SliderUpdate {
    
    __weak typeof(self)WeakSelf = self;
    
    CMTime time = CMTimeMakeWithSeconds(self.playProgress.value, 1.0);
    [self.playerItem seekToTime:time completionHandler:^(BOOL finished) {
        if (finished) {
            WeakSelf.playTime.text = [WeakSelf p_SecondsToMinute:self.playProgress.value];
        }
    }];
}

- (void)p_SliderEnd {
    
    _isSlidering = NO;
    [self p_Play];
}

#pragma mark -时间转换相关

//将秒数转化成 00:00 格式返回
- (NSString *)p_SecondsToMinute:(CGFloat)seconds {
    
    NSInteger min = (NSInteger)seconds / 60;
    NSInteger sec = (NSInteger)seconds % 60;
    
    NSString *minStr = [NSString stringWithFormat:@"%.2zd:%.2zd",min,sec];
    return minStr;
}

#pragma mark -是否隐藏上下View

- (void)p_TouchPlayView {
    
    if (_isHiddenView) {
        self.topView.hidden = self.bottomView.hidden = NO;
        _isHiddenView = NO;
    }else {
        self.topView.hidden = self.bottomView.hidden = YES;
        _isHiddenView = YES;
    }
}

- (void)dealloc {

    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
