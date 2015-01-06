//
//  RootViewController.h
//  Recording
//
//  Created by jieyuexi on 14-6-11.
//  Copyright (c) 2014年 www.hefengxin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioRecordingServices.h"

@interface RootViewController : UIViewController<AudioRecordingServicesDelegate>
{
    
    IBOutlet UIButton *reording;
    IBOutlet UIButton *stopRecording;
    IBOutlet UIButton *play;
    
    
    IBOutlet UISegmentedControl *segment;
    
    IBOutlet UISegmentedControl *segmentA;
    IBOutlet UILabel *audioName;
    IBOutlet UILabel *audioSizeLB;
    IBOutlet UILabel *audioLengthLB;
    
    IBOutlet UILabel *YSaudioSizeLB;
    IBOutlet UILabel *JYaudioSizeLB;
    
    
    
}

@end
