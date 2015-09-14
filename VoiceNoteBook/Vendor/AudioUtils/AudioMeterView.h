//
//  AudioMeterView.h
//
//  Created by Applex on 13-8-11.
//  Copyright (c) 2013 - 2014 cn.edu.nju All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioMeterView : UIView

@property (nonatomic, assign) BOOL recordingCancellable;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL reachingOutside;


- (void)postErrorMessage:(NSString *)errorMessage duration:(NSTimeInterval)duration;
- (void)updateViewWithPeakPower:(CGFloat)peakPower averagePower:(CGFloat)averagePower;

- (void)clearHintMessage;
- (void)setHintText:(NSString *)hintText;
@end
