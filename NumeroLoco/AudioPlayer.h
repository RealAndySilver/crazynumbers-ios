//
//  AudioPlayer.h
//  NumeroLoco
//
//  Created by Developer on 20/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface AudioPlayer : NSObject
@property (strong, nonatomic) AVAudioPlayer *shakerPlayer;
+(AudioPlayer *)sharedInstance;
-(void)playBackSound;
-(void)playButtonPressSound;
-(void)playWinSound;
-(void)playRestartSound;
-(void)playShakeSound;
-(void)stopShakeSound;
-(void)playAlarmSound;
-(void)pauseShakeSound;
@end
