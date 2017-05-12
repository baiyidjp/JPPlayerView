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
 传入播放源
 
 @param newUrl 本地或者网络URL
 @param tipTitle 标题
 */
- (void)updatePlayWithNewUrl:(NSURL *)newUrl tipTitle:(NSString *)tipTitle;

/** superViewController 预留如果有跳转可以传入跳转使用 */
@property(nonatomic,strong) UIViewController *superViewController;

@end
