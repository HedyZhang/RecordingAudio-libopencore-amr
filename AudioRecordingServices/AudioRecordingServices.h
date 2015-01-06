//
//  AudioRecordingServices.h
//  Recording
//
//  Created by jieyuexi on 14-6-11.
//  Copyright (c) 2014年 www.hefengxin.com. All rights reserved.
//


/*
 *  导入: AVFoundation.framework框架
 *  导入: AudioToolbox.framework框架
 *
 */


/**
 *  输出方式枚举值(0:扬声器 // 1:听筒 // 2:根据手机位置自己调整)
 */
enum outPutEnum
{
    speaker = 0,
    earpiece = 1,
    autoChoose = 2
};

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceConverter.h"
@protocol AudioRecordingServicesDelegate <NSObject>
@required

/**
 *  代理回调方法
 *
 *  @param audioInfo 录音文件信息字典
 */
- (void)getRecordAudioInfoDic:(NSDictionary *)audioInfo;

@end



@interface AudioRecordingServices : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    AVAudioRecorder * recorder;
    AVAudioPlayer   * audioPlayer;
    AVAudioSession  * audioSession;
    BOOL              isRecording;
    
    NSString        * fileName;
    NSString        * filePath;
    NSString        * fileLength;
    float             fileSize;
    
    NSMutableString * startTime;
    NSMutableString * endTime;
}

@property (nonatomic, assign)id<AudioRecordingServicesDelegate> delegate;


/**
 *  autoPlay: 是否自动播放(YES:setPlayAudioWithFilePath方法执行后直接播放; NO: 调用play方法播放)
 */
@property (nonatomic, assign)BOOL autoPlay;



/**
 *  设定输出方式(枚举值):(speaker = 0:扬声器 // earpiece = 1:听筒 // autoChoose = 2:自适应)
 */
@property (nonatomic, assign)enum outPutEnum outPutType;




/**
 *  初始化方法
 *
 *  @param delegate 指定代理
 *
 *  @return 音频处理类对象
 */
- (id)initWithDelegate:(id<AudioRecordingServicesDelegate>)delegate;





/**
 *  开始录音
 */
- (void)startAudioRecording;





/**
 *  结束录音
 */
- (void)stopAudioRecording;





/**
 *  播放录音
 *
 *  @param audioFilePath 文件路径名称
 *
 *  如果设置了自动播放属性为YES,则无需再调用play方法,(autoPlay默认为NO,不自动播放,则需调用Play方法)
 */
- (void)setPlayAudioWithFilePath:(NSString *)audioFilePath;




/**
 > 播放录音
 */
- (void)play;





/**
 *  播放暂停
 */
- (void)pause;



/**
 *  完成音频从WAV格式到AMR格式的转换(压缩)
 *
 *  @param audioFileName 待压缩WAV格式音频名称
 *
 *  @return 压缩后Amr音频信息字典
 */
- (NSDictionary *)compressionAudioFileWith:(NSString *)audioFileName;





/**
 *  完成音频从AMR格式到WAV格式的转换(解压)
 *
 *  @param audioFileName 待解压AMR格式音频名称
 *
 *  @return 解压后Wav音频信息字典
 */
- (NSDictionary *)decompressionAudioFileWith:(NSString *)audioFileName;


@end
























