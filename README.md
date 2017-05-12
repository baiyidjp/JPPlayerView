# JPPlayerView
- 支持本地播放/网络播放/切换全屏的 简单播放器
- 调用需要拖入文件夹 JPAVPlayerView 至自己项目中

```
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
```
- 引用

```
//使用类方法实例化播放器View
_avPlayerView = [JPAVPlayerView getPlayerView];
//加入View上
[self.view addSubview:_avPlayerView];
//类方法的frame是写死的 自定义frame的情况可以使用 系统的构造函数创建View 并传入一个frame
- (instancetype)initWithFrame:(CGRect)frame
```
```
//更换视频源
- (IBAction)changeOnlineMovie:(id)sender {
    
    [_avPlayerView updatePlayWithNewUrl:[NSURL URLWithString:@"http://192.168.168.1/IXC68713b6ba85091d4333e7623fc37d195/f2ceb0ec31273a47604e7868993808d0/5915281c/video/m/220a64784c4bffc405b93332067a7a7843d114586b000021696c229e8d/"] tipTitle:@"大漠风情"];
}

- (IBAction)changeMoviePath:(id)sender {
    
    NSString *logoFilePath = [[NSBundle mainBundle] pathForResource:@"四大装逼.mp4" ofType:nil];
    [_avPlayerView updatePlayWithNewUrl:[NSURL fileURLWithPath:logoFilePath] tipTitle:@"最服四大装逼"];
}
```
![录制](https://github.com/baiyidjp/JPPlayerView/blob/master/PlayMovie/JPAVPlayerView/Images/%E8%A7%86%E9%A2%91%E6%92%AD%E6%94%BE.gif?raw=true)
