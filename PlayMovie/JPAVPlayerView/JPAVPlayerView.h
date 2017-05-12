//
//  JPAVPlayerView.h
//  PlayMovie
//
//  Created by Keep丶Dream on 2017/5/9.
//  Copyright © 2017年 dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface JPAVPlayerView : UIView


/**
 获取一个播放器View

 @return View
 */
+ (instancetype)getPlayerView;

/**
 更换视频源

 @param newUrl 新的视频的地址
 */
- (void)updatePlayWithNewUrl:(NSURL *)newUrl tipTitle:(NSString *)tipTitle;

/** superViewController */
@property(nonatomic,strong) UIViewController *superViewController;

@end
