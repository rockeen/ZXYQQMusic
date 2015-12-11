//
//  AppDelegate.m
//  QQ音乐
//
//  Created by Rockeen on 15/12/10.
//  Copyright © 2015年 https://github.com/rockeen. All rights reserved.
//

#import "AppDelegate.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface AppDelegate ()
{
    UIView *bottomView;//底部视图
    
    UIImageView *backView;//背景视图
    
    UILabel *songLabel;//歌曲的名字
    
    UILabel *singerLabel;//歌手的名字
    
    UILabel *totalLabel;//歌曲总时长
    
    NSTimer *timer;//定时器
    
    UISlider *slider;//滑块
    
    UIButton *playBtn;//播放按钮
    
    UILabel *startLabel;//歌曲进度时间label
    
    NSArray *musics;//存放数据的数组
    
    NSInteger currentIndex;//当前歌曲下标
    
    UIButton *rightBtn;//点赞btn

    BOOL isLove[4];//bool数组
    
    UIView *topView;//顶部视图
    
    
    AVAudioPlayer *  audioplayer;//播放器

}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window  = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController=[[UIViewController alloc]init];
    
    [self.window makeKeyAndVisible];
    
    
    //设置当前下标的初始值
    currentIndex = 0;
    
    //创建背景视图
    [self createBackGroundView];
    
    //创建顶部视图
    [self createTopView];
    
    //创建尾部视图
    [self createBottomView];
    
    //创建滑动条
    [self createSlider];
    
    
    //获取数据
    [self loadData];
    return YES;
}

-(void)loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"music.plist" ofType:nil];
    
    musics = [NSArray arrayWithContentsOfFile:path];
    
    [self reloadData];
}

//刷新数据
-(void)reloadData
{
    NSDictionary *zjl = musics[currentIndex];
    
    NSString *imgName = [zjl objectForKey:@"image"];
    
    backView.image = [UIImage imageNamed:imgName];
    
    songLabel.text = [zjl objectForKey:@"song"];
    
    singerLabel.text = [zjl objectForKey:@"singer"];
    
    totalLabel.text = [zjl objectForKey:@"total"];
    
    NSString *totalTime = [zjl objectForKey:@"total"];
    
    slider.maximumValue = [self strToFloat:totalTime];
    
    //每次刷新数据使value等于0
    slider.value = 0;
    
    //每次刷新数据时 重新设置startLabel
    startLabel.text = [self floatToStr:slider.value];
    
    //根据bool数组中的记录值 设置点赞按钮的选中状态
    rightBtn.selected = isLove[currentIndex];
    
}



#pragma mark-----音乐播放

-(void)startPlayer:(NSString *)name
{
    
    
    
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    
    
    //定义URL  NSBundle获取文件路径
    NSURL *audioPath=[[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"mp3"]];
    NSError *error=nil;
    
    //audioPlayer初始化
    audioplayer=[[AVAudioPlayer alloc]initWithContentsOfURL:audioPath error:&error];
    

    
    //设置代理
    audioplayer.delegate=self;
    //判断是否错误
    if(error!=nil)
    {
        NSLog(@"播放遇到错误了 信息：%@",[error description]);
        return ;
    }
    //开始播放
    [audioplayer play];
}



//暂停
 - (void)pause
{
     [audioplayer pause];
}


//停止播放方法
- (void)stopPlayer
{
    [audioplayer stop];
}





//将字符串时间转化为float类型
-(float)strToFloat:(NSString *)totalTime
{
    
    //截取分钟
    NSString *min = [totalTime substringWithRange:NSMakeRange(0, 2)];
    //截取秒
    NSString *sec = [totalTime substringWithRange:NSMakeRange(3, 2)];
    //将字符串转化为float
    float time = [min floatValue]*60 + [sec floatValue];
    //返回该时间
    return time;
    
}

//将float数字转换成时间字符串
-(NSString *)floatToStr:(float)value
{
    //将value分成分钟（min） 和 秒（sec）
    int min = value/60;
    
    int sec = (int)value%60;
    
    //拼接成字符串
    NSString *time = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    
    return time;
}



#pragma mark-----//创建滑动条

-(void)createSlider
{
    //初始化滑块
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, -10, kScreenW, 30)];
    
    [bottomView addSubview:slider];
    
    //设置正常状态下图片
    [slider setThumbImage:[UIImage imageNamed:@"com_thumb_max_n-Decoded"] forState:UIControlStateNormal];
    
    //添加滑动事件
    [slider addTarget:self action:@selector(sliderAct:) forControlEvents:UIControlEventValueChanged];
    
    //设置滑块最小值
    slider.minimumValue = 0;
    
    //初始化当前value值
    slider.value = 0;
    
}

//滑块响应事件
-(void)sliderAct:(UISlider *)slider
{
    //当滑动滑块时  修改当前歌曲播放时长文本
    startLabel.text = [self floatToStr:slider.value];
    
    //播放
    
//    NSLog(@"%f",slider.value);
    audioplayer.currentTime=slider.value;
    
    
    
    
}



#pragma mark-----//创建尾部视图

-(void)createBottomView
{
    //创建底部视图
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH-100, kScreenW, 100)];
    
    bottomView.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.1];
    
    
    [self.window addSubview:bottomView];
    
    //创建btn
    playBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenW/2-60/2, (100-60)/2, 60, 60)];
    
    //播放按钮添加正常状态下图片
    [playBtn setImage:[UIImage imageNamed:@"playing_btn_play_n@2x"] forState:UIControlStateNormal];
    
    //播放按钮添加选中状态下图片
    [playBtn setImage:[UIImage imageNamed:@"playing_btn_pause_n@2x"] forState:UIControlStateSelected];
    
    //播放按钮添加高亮状态下图片
    [playBtn setImage:[UIImage imageNamed:@"playing_btn_play_h@2x"] forState:UIControlStateHighlighted];
    
    //添加点击事件
    [playBtn addTarget:self action:@selector(playBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:playBtn];
    
    
    //创建上一首按钮
    UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, (100-50)/2, 50, 50)];
    
    //设置正常状态下图片
    [lastBtn setImage:[UIImage imageNamed:@"playing_btn_pre_h@2x"] forState:UIControlStateNormal];
    
    //设置高亮状态下图片
    [lastBtn setImage:[UIImage imageNamed:@"playing_btn_pre_h@2x"] forState:UIControlStateHighlighted];
    
    //设置高亮状态下图片
    [lastBtn setImage:[UIImage imageNamed:@"playing_btn_pre_n@2x"] forState:UIControlStateNormal];
    
    //添加点击事件
    [lastBtn addTarget:self action:@selector(lastBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:lastBtn];
    
    //创建上一首按钮
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenW-80-50, (100-50)/2, 50, 50)];
    
    //设置正常状态下图片
    [nextBtn setImage:[UIImage imageNamed:@"playing_btn_next_n@2x"] forState:UIControlStateNormal];
    
    //设置高亮状态下图片
    [nextBtn setImage:[UIImage imageNamed:@"playing_btn_next_h@2x"] forState:UIControlStateHighlighted];
    
    //添加点击事件
    [nextBtn addTarget:self action:@selector(nextBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:nextBtn];
    
    
    //添加起始时间label
    startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    startLabel.text = @"00:00";
    
    startLabel.textColor = [UIColor whiteColor];
    
    [bottomView addSubview:startLabel];
    
    //添加总时长label
    totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW-100, 0, 100, 30)];
    
    totalLabel.textAlignment = NSTextAlignmentRight;
    
    totalLabel.textColor = [UIColor whiteColor];
    
    [bottomView addSubview:totalLabel];
    
}

//上一首歌
-(void)lastBtnAct:(UIButton *)lastBtn
{
    if(currentIndex>0)
    {
        currentIndex--;
        [self reloadData];
    }
    else
    {
        currentIndex = 3;
        
        [self reloadData];
    }
    
    if (playBtn.selected==YES) {
        //播放音乐
        [self startPlayer:songLabel.text];
        audioplayer.currentTime=slider.value;
    }

}

//下一首歌
-(void)nextBtnAct:(UIButton *)nextBtn
{
    //判断当前歌曲下标是否小于三
    if (currentIndex<3) {
        //下标加1
        currentIndex++;
        //刷新界面数据
        [self reloadData];
        
    }
    else
    {
        //如果大于3 那么将currentIndex设置为0  从第一个开始展示
        currentIndex = 0;
        //刷新界面数据
        [self reloadData];
    }
    
    if (playBtn.selected==YES) {
        //播放音乐
        [self startPlayer:songLabel.text];
        audioplayer.currentTime=slider.value;
    }
    

    
}

//点击暂停和播放
-(void)playBtnAct:(UIButton *)playbtn
{
    
    if (!playbtn.selected) {
        //创建一个定时器
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
        
        //设置playBtn为选中状态为Yes
        playbtn.selected = YES;
        
        //播放音乐
        [self startPlayer:songLabel.text];
        audioplayer.currentTime=slider.value;
        
    }
    else
    {
        //取消定时器
        [timer invalidate];
        timer = nil;
        
        //设置playBtn的选中状态为NO
        playbtn.selected = NO;
        
        //暂停播放
        [self pause];
    }
    
    
}

//定时器方法
-(void)timer:(NSTimer *)timer
{
    //判断当前slider的value是否小于slider的最大value
    if (slider.value<slider.maximumValue) {
        //如果是value值加1
        slider.value++;
        
        //设置当前歌曲播放时长文本
        startLabel.text = [self floatToStr:slider.value];
    }
    else
    {
        //如果不是说明歌曲播放完毕
        [timer invalidate];
        timer = nil;
        
        //暂停状态
        playBtn.selected = NO;
    }
}



#pragma mark-----//创建顶部视图

-(void)createTopView
{
    //创建顶部视图
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 64)];
    
    [self.window addSubview:topView];
    
    //设置背景灰色
    topView.backgroundColor = [UIColor grayColor];
    
//    topView.alpha=.7;
    
    //添加左侧按钮
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 44, 44)];
    
    [topView addSubview:leftBtn];
    
    [leftBtn setImage:[UIImage imageNamed:@"top_back_white"] forState:UIControlStateNormal];
    
    [leftBtn addTarget:self action:@selector(leftbtnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加右侧按钮
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenW-5-44, 20, 44, 44)];
    
    [topView addSubview:rightBtn];
    
    [rightBtn addTarget:self action:@selector(rightBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置正常状态下图片
    [rightBtn setImage:[UIImage imageNamed:@"playing_btn_love@2x"] forState:UIControlStateNormal];
    
    //设置选中状态下图片
    [rightBtn setImage:[UIImage imageNamed:@"playing_btn_in_myfavor@2x"] forState:UIControlStateSelected];
    
    //设置高亮状态下图片
    [rightBtn setImage:[UIImage imageNamed:@"playing_btn_in_myfavor_h@2x"] forState:UIControlStateHighlighted];
    
    //创建Label标题
    songLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW/2-(200/2), 20, 200, 24)];
    
    //    songLabel.backgroundColor = [UIColor yellowColor];
    
    //设置label文本属性
    songLabel.textAlignment = NSTextAlignmentCenter;
    songLabel.font = [UIFont systemFontOfSize:20];
    songLabel.textColor = [UIColor whiteColor];
    [topView addSubview:songLabel];
    
    //创建歌手的label
    singerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW/2-(200/2), 20+24, 200, 20)];
    
    //设置label文本属性
    //设置文本对齐方式 居中
    singerLabel.textAlignment = NSTextAlignmentCenter;
    
    singerLabel.font = [UIFont systemFontOfSize:16];
    
    singerLabel.textColor = [UIColor whiteColor];
    
    [topView addSubview:singerLabel];
}

-(void)rightBtnAct:(UIButton *)rightBtn
{
    //通过bool类型数组记录每首歌的选中（点赞）状态
    isLove[currentIndex] = !isLove[currentIndex];
    //根据记录值设置选中状态
    rightBtn.selected = isLove[currentIndex];
    
}

- (void)leftbtnAct:(UIButton *)leftButton{

    //初始化actionSheet实例
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"确定退出"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"退出"
                                  otherButtonTitles: nil];
    
    //设置actionSheet的类型 一般使用默认类型
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    //actionSheet显示在哪个视图上
    [actionSheet showInView:self.window];
    








}

#pragma mark-----UIActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        exit(0);
    }
    else if (buttonIndex == 1)
    {

    }
    
}








#pragma mark-----创建背景视图

-(void)createBackGroundView
{
    //初始化背景视图
    backView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    
    backView.backgroundColor = [UIColor whiteColor];
    
    [self.window addSubview:backView];
    
    //打开触摸响应事件
    backView.userInteractionEnabled = YES;
    
    //创建一个button
    UIButton *btn = [[UIButton alloc] initWithFrame:backView.bounds];
    
    //添加响应事件
    [btn addTarget:self action:@selector(btnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:btn];
}

//背景视图的点击方法
-(void)btnAct:(UIButton *)btn
{
    //隐藏顶部和底部视图
    //根据btn的选中状态设置 隐藏和显示其它视图
    if (!btn.selected) {
        //选中状态 全改为透明度0
        [UIView animateWithDuration:.5 animations:^{
            //            topView.hidden = YES;
            //            bottomView.hidden = YES;
            
            topView.alpha = 0;
            
            bottomView.alpha = 0;
        }];
        
        btn.selected = YES;
    }
    else
    {
        //非选中状态 全改为透明度1
        [UIView animateWithDuration:.5 animations:^{
            
            topView.alpha = 1;
            bottomView.alpha = 1;
            
        }];
        
        btn.selected = NO;
    }
}


@end
