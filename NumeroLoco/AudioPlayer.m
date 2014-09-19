//
//  AudioPlayer.m
//  NumeroLoco
//
//  Created by Developer on 20/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AudioPlayer.h"

@interface AudioPlayer()
@property (strong, nonatomic) AVAudioPlayer *backSoundPlayer;
@property (strong, nonatomic) AVAudioPlayer *buttonPressSound;
@property (strong, nonatomic) AVAudioPlayer *winSound;
@property (strong, nonatomic) AVAudioPlayer *restartSound;
@end

@implementation AudioPlayer

-(AVAudioPlayer *)restartSound {
    if (!_restartSound) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"restartnuevo" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
        _restartSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [_restartSound prepareToPlay];
    }
    return _restartSound;
}

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

-(AVAudioPlayer *)shakerPlayer {
    if (!_shakerPlayer) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Shaker" ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
        _shakerPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        _shakerPlayer.enableRate = YES;
        [_shakerPlayer prepareToPlay];
    }
    return _shakerPlayer;
}

-(AVAudioPlayer *)alarmSound {
    if (!_alarmSound) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Alarm" ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
        _alarmSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [_alarmSound prepareToPlay];
    }
    return _alarmSound;
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

-(void)playAlarmSound {
    [self.alarmSound play];
}

-(void)playShakeSound {
    self.shakerPlayer.volume = [self getVolumeSavedInUserDefaults];
    [self.shakerPlayer play];
}

-(float)getVolumeSavedInUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"volume"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] floatValue];
    } else {
        return 1.0;
    }
}

-(void)pauseShakeSound {
    [self.shakerPlayer pause];
}

-(void)stopShakeSound {
    [self.shakerPlayer stop];
    self.shakerPlayer.currentTime = 0;
}

-(void)playRestartSound {
    [self.restartSound play];
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
