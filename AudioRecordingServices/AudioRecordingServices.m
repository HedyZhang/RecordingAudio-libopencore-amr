//
//  AudioRecordingServices.m
//  Recording
//
//  Created by jieyuexi on 14-6-11.
//  Copyright (c) 2014年 www.hefengxin.com. All rights reserved.
//

#import "AudioRecordingServices.h"
@implementation AudioRecordingServices

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (id)initWithDelegate:(id<AudioRecordingServicesDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.autoPlay = NO;
        isRecording = NO;
    }
    return self;
}


#pragma mark - 开始录音
- (void)startAudioRecording
{
    NSLog(@"-------startTime = %@", [AudioRecordingServices systemTime]);
    if (!isRecording)
    {
        startTime = [[NSMutableString stringWithString:[AudioRecordingServices systemTime]] retain];
        //设置文件名和录音路径
        
        isRecording = YES;
        fileName = [[AudioRecordingServices systemTime] retain];
        filePath = [[AudioRecordingServices getPathByFileName:fileName ofType:@"wav"] retain];
        
        //初始化录音
        NSURL * url = [[[NSURL alloc] initFileURLWithPath:filePath] autorelease];
        recorder = [[AVAudioRecorder alloc]initWithURL:url
                                              settings:[AudioRecordingServices getAudioRecorderSettingDict]
                                                 error:nil];
        [recorder setDelegate:self];
        [recorder setMeteringEnabled:YES];
        [recorder prepareToRecord];
        
        //开始录音
        audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        [recorder record];
    }
}


- (void)setOutPutType:(enum outPutEnum)outPutType
{
    _outPutType = outPutType;
}



#pragma mark - 结束录音
- (void)stopAudioRecording
{
    endTime = [[NSMutableString stringWithString:[AudioRecordingServices systemTime]] retain];
    NSLog(@"---------endTime = %@", endTime);
    fileLength = [AudioRecordingServices returnUploadTime:startTime];

    isRecording = NO;
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [recorder stop];
    fileSize  = [AudioRecordingServices getFileSize:filePath] / 1000;
}


#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state];
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"UIDeviceProximityStateDidChangeNotification"
                                                      object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:nil];
    else
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                               error:nil];
}




#pragma mark - 设置播放路径(如果开启自动播放,则不需调用play方法就可直接播放)
- (void)setPlayAudioWithFilePath:(NSString *)audioFilePath
{
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioFilePath]
                                                         error:nil];
    [audioPlayer setDelegate:self];
    if (_autoPlay) [self play];

}

#pragma mark - 播放
- (void)play
{
    
    switch (_outPutType)
    {
        case 0:
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                   error:nil]; //设置输出方式
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //关闭红外
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"UIDeviceProximityStateDidChangeNotification"
                                                          object:nil]; //移除观察者
            break;
        }
            
        case 1:
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                   error:nil]; //设置输出方式
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //关闭红外
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"UIDeviceProximityStateDidChangeNotification"
                                                          object:nil]; //移除观察者
        }
            
            break;
        case 2:
            [self handleNotification:YES];
            break;
            
        default:
            break;
    }
    if (audioPlayer) [audioPlayer play];
}


#pragma mark - 播放暂停
- (void)pause
{
    if (audioPlayer) [audioPlayer pause];
}




#pragma mark - 压缩文件(wav -> amr)
- (NSDictionary *)compressionAudioFileWith:(NSString *)audioFileName
{
    NSString * newName = [audioFileName stringByAppendingString:@"toAmr"];
    //转格式
    [VoiceConverter wavToAmr:[AudioRecordingServices getPathByFileName:audioFileName ofType:@"wav"] amrSavePath:[AudioRecordingServices getPathByFileName:newName ofType:@"amr"]];
    
    NSString * newFilePath = [[AudioRecordingServices getPathByFileName:newName ofType:@"amr"] retain];
    float      newFileSize = [AudioRecordingServices getFileSize:newFilePath] / 1000;
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setObject:newName forKey:@"fileName"];
    [infoDic setObject:newFilePath forKey:@"filePath"];
    [infoDic setObject:[NSString stringWithFormat:@"%.0f", newFileSize] forKey:@"fileSize"];
    
    return infoDic;
}



#pragma mark - 解压文件(amr -> wav)
- (NSDictionary *)decompressionAudioFileWith:(NSString *)audioFileName
{
    NSString * newName = [audioFileName stringByAppendingString:@"toWav"];
    //转格式
    [VoiceConverter amrToWav:[AudioRecordingServices getPathByFileName:audioFileName
                                                                ofType:@"amr"]
                 wavSavePath:[AudioRecordingServices getPathByFileName:newName
                                                                ofType:@"wav"]];
    
    NSString * newFilePath = [[AudioRecordingServices getPathByFileName:newName
                                                                 ofType:@"wav"] retain];
    
    float      newFileSize = [AudioRecordingServices getFileSize:newFilePath] / 1000;
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setObject:newName forKey:@"fileName"];
    [infoDic setObject:newFilePath forKey:@"filePath"];
    [infoDic setObject:[NSString stringWithFormat:@"%.0f", newFileSize] forKey:@"fileSize"];
    
    return infoDic;
}


#pragma mark - 获取录音设置
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithInt:-10],AVSampleRateConverterAlgorithmKey,
                                   [NSNumber numberWithFloat: 100.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    
    return [recordSetting autorelease];
}



#pragma mark - 获取系统时间
+ (NSString *)systemTime
{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc]init] autorelease];
    [formatter setDateFormat:@"YYMMddhhmmss"];

    return [formatter stringFromDate:[NSDate date]];
}





#pragma mark - 获取时间差
+ (NSString *)returnUploadTime:(NSString *)time
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYYMMddhhmmss"];
    NSDate *d=[date dateFromString:time];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString * timeString=@"";
    NSTimeInterval cha = now-late;
    NSInteger ss = [[NSString stringWithFormat:@"%0.f", cha] integerValue];
    
    NSInteger hour = 0, minute = 0, second = 0;
    if (ss >= 3600)
    {
        hour = ss / 3600;
        minute = ss % 3600 / 60;
        second = ss % 3600 % 60;
    }else if (ss >= 60)
    {
        minute = ss / 60;
        second = ss % 60;

    }else if (ss < 60)
    {
        second = ss;
    }
    
    NSLog(@"录音时长 %d:%d'%d\"", hour, minute, second);
    [date release];
    if (hour != 0)
        return timeString = [NSString stringWithFormat:@"%d:%d'%d\"", hour, minute, second];
    else if (minute != 0)
        return timeString = [NSString stringWithFormat:@"%d'%d\"", minute, second];
    else
        return timeString = [NSString stringWithFormat:@"%d\"", second];
}


#pragma mark - 获取文件大小
+ (NSInteger)getFileSize:(NSString*)path
{
    NSFileManager * filemanager = [[[NSFileManager alloc]init] autorelease];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}



#pragma mark - 通过名字及类型获得文件路径
/**
 *  通过名字及类型获得文件路径
 *
 *  @param fileName 文件名
 *  @param type     文件类型
 *
 *  @return 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)fileName ofType:(NSString *)type
{
    NSString* fileDirectory = [[[AudioRecordingServices getCacheDirectory]stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:type];
    return fileDirectory;
}



#pragma mark - 获得缓存路径
/**
 *  获取缓存路径
 *
 *  @return 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0]stringByAppendingPathComponent:@"Voice"];
}





#pragma mark - AVAudioPlayer Delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self handleNotification:NO];
    if (flag) [audioPlayer prepareToPlay ];
    NSLog(@"---------播放完毕");
}

// 解码错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"---------解码错误！");
}

// 当音频播放过程中被中断时
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"-------中断,暂停播放");
    [audioPlayer pause];
}

// 当中断结束时
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    NSLog(@"--------中断结束，恢复播放");
    [audioPlayer play];
}



#pragma mark - AVAudioRecorder Delegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(getRecordAudioInfoDic:)])
    {
        NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [infoDic setObject:fileName forKey:@"fileName"];
        [infoDic setObject:filePath forKey:@"filePath"];
        [infoDic setObject:[NSString stringWithFormat:@"%@", fileLength] forKey:@"fileLength"];
        [infoDic setObject:[NSString stringWithFormat:@"%.0f", fileSize] forKey:@"fileSize"];
        
        [self.delegate getRecordAudioInfoDic:infoDic];

    }
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error //录制编码错误
{
    NSLog(@"编码错误: %@", error);
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder; //录制开始中断
{
    NSLog(@"录制发生中断");
    [self stopAudioRecording];
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags //录制已经中断
{
    NSLog(@"录制结束中断: %ld", (unsigned long)flags );
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags
{
    NSLog(@"录制结束中断: %ld", (unsigned long)flags);
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    NSLog(@"录制结束中断");
}



#pragma mark - dealloc
- (void)dealloc
{
    [recorder release];
    [audioPlayer release];
    [audioSession release];
    [fileName release];
    [filePath release];

    [super dealloc];
}


@end
