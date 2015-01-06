//
//  RootViewController.m
//  Recording
//
//  Created by jieyuexi on 14-6-11.
//  Copyright (c) 2014年 www.hefengxin.com. All rights reserved.
//

#import "RootViewController.h"
@interface RootViewController ()
{
    AudioRecordingServices * audio;
    NSString       * audioFilePath;
    NSDictionary   * audioDic;
    NSDictionary   * wavDir;
    NSString       * endPath;
}
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    audio  = [[AudioRecordingServices alloc] initWithDelegate:self];
    
     
    
    
    [segment addTarget:self action:@selector(seg:) forControlEvents:UIControlEventValueChanged];
    segment.tag = 1000;
    [segmentA addTarget:self action:@selector(seg:) forControlEvents:UIControlEventValueChanged];
    segmentA.tag = 2000;
    /*
    for(NSString *familyName in [UIFont familyNames])
    {
        NSLog(@"familyName = %@", familyName);
        
        for(NSString *fontName in [UIFont fontNamesForFamilyName:familyName])
        {
            NSLog(@"\tfontName = %@", fontName);
        }
    }
     */
    

}






- (void)seg:(UISegmentedControl *)sender
{
    if(sender.tag == 1000)
    {
        if (sender.selectedSegmentIndex == 0) audio.autoPlay = NO;
        if (sender.selectedSegmentIndex == 1) audio.autoPlay = YES;
    }
    
    if (sender.tag == 2000)
    {
        if (sender.selectedSegmentIndex == 0) audio.outPutType = 0;
        if (sender.selectedSegmentIndex == 1) audio.outPutType = 1;
        if (sender.selectedSegmentIndex == 2) audio.outPutType = 2;
    }
}

#pragma mark - 录音 / 播放

- (IBAction)record:(UIButton *)sender
{
    [audio  startAudioRecording];
    audioName.text = @"";
    audioSizeLB.text = @"";
    YSaudioSizeLB.text = @"";
    JYaudioSizeLB.text = @"";
    audioLengthLB.text = @"";
}


- (IBAction)stopRecord:(UIButton *)sender
{
    [audio stopAudioRecording];
}


- (IBAction)play:(UIButton *)sender
{
    [audio setPlayAudioWithFilePath:audioFilePath];
}



- (IBAction)stop:(UIButton *)sender
{
    [audio pause];
}


- (IBAction)again:(UIButton *)sender
{
    [audio play];
}


- (IBAction)YS:(UIButton *)sender
{
    
    NSDictionary * newDic = [audio compressionAudioFileWith:[audioDic objectForKey:@"fileName"]];
    YSaudioSizeLB.text = [newDic objectForKey:@"fileSize"];
    NSLog(@"压缩后为:  %@", newDic);
    wavDir = [[NSDictionary dictionaryWithDictionary:newDic] retain];
}


- (IBAction)JY:(UIButton *)sender
{
   NSDictionary * dic =  [audio decompressionAudioFileWith:[wavDir objectForKey:@"fileName"]];
    JYaudioSizeLB.text = [dic objectForKey:@"fileSize"];
    endPath = [dic objectForKey:@"filePath"];
    NSLog(@"解压后为: %@", dic);
}

- (IBAction)playNew:(UIButton *)sender
{
    audio.autoPlay = YES;
    NSLog(@"最终路径: %@", endPath);
    [audio setPlayAudioWithFilePath:endPath];
    
}





#pragma mark -  AudioRecording Delegate
- (void)getRecordAudioInfoDic:(NSDictionary *)audioInfo
{
    NSLog(@"录制生成 : %@", audioInfo);
    audioDic = [[NSDictionary dictionaryWithDictionary:audioInfo] retain];
    audioFilePath = [audioInfo objectForKey:@"filePath"];
    audioName.text = [audioInfo objectForKey:@"fileName"];
    audioSizeLB.text = [NSString stringWithFormat:@"%@ kb", [audioInfo objectForKey:@"fileSize"]];
    audioLengthLB.text = [NSString stringWithFormat:@"%@", [audioInfo objectForKey:@"fileLength"]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [reording release];
    [stopRecording release];
    [play release];
    [segment release];
    [audioName release];
    [audioSizeLB release];
    [YSaudioSizeLB release];
    [JYaudioSizeLB release];
    [segmentA release];
    [audioLengthLB release];
    [super dealloc];
}
@end
