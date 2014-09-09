//
//  AudioPlayer.m
//  NumeroLoco
//
//  Created by Developer on 20/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AudioPlayer.h"
@import AVFoundation;

@interface AudioPlayer()
@property (strong, nonatomic) AVAudioPlayer *backSoundPlayer;
@property (strong, nonatomic) AVAudioPlayer *buttonPressSound;
@property (strong, nonatomic) AVAudioPlayer *winSound;
@end

@implementation AudioPlayer

-(AVAudioPlayer *)backSoundPlayer {
    if (!_backSoundPlayer) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
        _backSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [_backSoundPlayer prepareToPlay];
    }
    return _backSoundPlayer;
}

-(AVAudioPlayer *)buttonPressSound {
    if (!_buttonPressSound) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"press" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
        _buttonPressSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [_buttonPressSound prepareToPlay];
    }
    return _buttonPressSound;
}

-(AVAudioPlayer *)winSound {
    if (!_winSound) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"win" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
        _winSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [_winSound prepareToPlay];
    }
    return _winSound;
}

+(AudioPlayer *)sharedInstance {
    static AudioPlayer *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[AudioPlayer alloc] init];
        });
    }
    return shared;
}

-(void)playBackSound {
    [self.backSoundPlayer stop];
    self.backSoundPlayer.currentTime = 0;
    [self.backSoundPlayer play];
}

-(void)playWinSound {
    [self.winSound play];
}

-(void)playButtonPressSound {
    [self.buttonPressSound stop];
    self.buttonPressSound.currentTime = 0;
    [self.buttonPressSound play];
}

@end
