//
//  ViewController.m
//  PlayMovie
//
//  Created by Keep丶Dream on 2017/5/9.
//  Copyright © 2017年 dong. All rights reserved.
//

#import "ViewController.h"
#import "JPAVPlayerView.h"

@interface ViewController ()

@end

@implementation ViewController
{
    JPAVPlayerView *_avPlayerView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _avPlayerView = [JPAVPlayerView getPlayerView];
    [self.view addSubview:_avPlayerView];
    NSString *logoFilePath = [[NSBundle mainBundle] pathForResource:@"logo.mp4" ofType:nil];
    [_avPlayerView updatePlayWithNewUrl:[NSURL fileURLWithPath:logoFilePath] tipTitle:@"神州数码Logo"];

}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changeOnlineMovie:(id)sender {
    
    [_avPlayerView updatePlayWithNewUrl:[NSURL URLWithString:@"http://192.168.168.1/IXC68713b6ba85091d4333e7623fc37d195/f2ceb0ec31273a47604e7868993808d0/5915281c/video/m/220a64784c4bffc405b93332067a7a7843d114586b000021696c229e8d/"] tipTitle:@"大漠风情"];
}

- (IBAction)changeMoviePath:(id)sender {
    
    NSString *logoFilePath = [[NSBundle mainBundle] pathForResource:@"四大装逼.mp4" ofType:nil];
    [_avPlayerView updatePlayWithNewUrl:[NSURL fileURLWithPath:logoFilePath] tipTitle:@"最服四大装逼"];
}

@end
