//
//  AudioPlayer.h
//  NumeroLoco
//
//  Created by Developer on 20/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlayer : NSObject
+(AudioPlayer *)sharedInstance;
-(void)playBackSound;
-(void)playButtonPressSound;
-(void)playWinSound;
-(void)playRestartSound;
@end
