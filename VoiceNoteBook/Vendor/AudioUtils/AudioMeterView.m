//
//  AudioMeterView.m
//
//  Created by Applex on 13-8-11.
//  Copyright (c) 2013 - 2014 cn.edu.nju All rights reserved.
//

#import "AudioMeterView.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger kMeterPlaceholderCount = 5;
static const CGFloat kMeterPlaceholderSideLength = 15.f;
static const CGFloat kMeterPlaceholderOriginX = 120.f;

static const CGFloat kMicrophonePlaceholderOriginY = 20.f;
static const CGFloat kMicrophonePlaceholderSideLength = 100.f;

@interface AudioMeterView ()

@property (strong, nonatomic) UIImageView *microphonePlaceholderView;
@property (strong, nonatomic) UILabel *hintTextView;
@property (assign, nonatomic) NSInteger peakSoundLevel;
@property (assign, nonatomic) NSInteger averageSoundLevel;

@end
@implementation AudioMeterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 15.f;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.microphonePlaceholderView];
        [self addSubview:self.hintTextView];
        
        self.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:0.7f];
        
        self.reachingOutside = NO;
        
        // This is to fix the default text in hint textview after setting reachingOutside=NO
        self.hintTextView.text = @"";
        
        self.peakSoundLevel = 0;
        self.averageSoundLevel = 0;
    }
    return self;
}


- (UILabel *)hintTextView
{
    if (_hintTextView == nil) {
        _hintTextView = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 130.f, 120.f, 20.f)];
        _hintTextView.font = [UIFont systemFontOfSize:12.f];
        _hintTextView.backgroundColor = [UIColor clearColor];
        _hintTextView.textColor = [UIColor whiteColor];
        _hintTextView.textAlignment = UITextAlignmentCenter;
        _hintTextView.layer.cornerRadius = 5.f;
    }
    return _hintTextView;
}

- (UIImageView *)microphonePlaceholderView
{
    if (_microphonePlaceholderView == nil) {
        _microphonePlaceholderView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, kMicrophonePlaceholderOriginY, kMicrophonePlaceholderSideLength, kMicrophonePlaceholderSideLength)];
    }
    return _microphonePlaceholderView;
}

- (void)setReachingOutside:(BOOL)reachingOutside
{
    if (reachingOutside) {
        self.microphonePlaceholderView.image = [UIImage imageNamed:@"audio-cancel"];
        self.microphonePlaceholderView.frame = CGRectMake(26.f, 20.f, 100.f, 100.f);
        
        self.hintTextView.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:0.f blue:0.f alpha:0.5f];
        self.hintTextView.text = NSLocalizedString(@"Release to cancel", @"");
        self.hintTextView.font = [UIFont boldSystemFontOfSize:12.f];
    } else {
        self.microphonePlaceholderView.image = [UIImage imageNamed:@"audio-microphone"];
        self.microphonePlaceholderView.frame = CGRectMake(10.f, 20.f, 100.f, 100.f);
        
        self.hintTextView.backgroundColor = [UIColor clearColor];
        self.hintTextView.text = self.recordingCancellable ? NSLocalizedString(@"Move up to cancel", @"") : NSLocalizedString(@"Is Recording...", @"");
        self.hintTextView.font = [UIFont systemFontOfSize:12.f];
    }
    _reachingOutside = reachingOutside;
}

- (void)postErrorMessage:(NSString *)errorMessage duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:1.f animations:^{
        self.hintTextView.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:0.f blue:0.f alpha:0.5f];
        self.hintTextView.text = errorMessage;
        self.hintTextView.font = [UIFont boldSystemFontOfSize:11.f];
    } completion:^(BOOL finished) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.1f;
        animation.repeatCount = 2;
        animation.autoreverses = YES;
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.hintTextView.center.x - 10.f, self.hintTextView.center.y)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.hintTextView.center.x + 10.f, self.hintTextView.center.y)]];
        [self.hintTextView.layer addAnimation:animation forKey:@"position"];
    }];
    [self performSelector:@selector(clearHintMessage) withObject:self afterDelay:duration];
}

- (void)clearHintMessage
{
    self.hintTextView.backgroundColor = [UIColor clearColor];
    self.hintTextView.text = @"";
}

- (void)setHintText:(NSString *)hintText
{
    self.hintTextView.text = hintText;
}

- (void)drawRect:(CGRect)rect
{
    NSInteger soundLevel = self.peakSoundLevel;
    if (self.microphonePlaceholderView.frame.origin.x > 10.f) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableArray *rectangleHeights = [NSMutableArray arrayWithCapacity:kMeterPlaceholderCount];
    float prevMeterPlaceholderY = kMicrophonePlaceholderSideLength + kMicrophonePlaceholderOriginY - kMeterPlaceholderSideLength;
    float meterPlaceholderHeight = kMicrophonePlaceholderSideLength / 5.0;
    
    for (int i = 0; i < kMeterPlaceholderCount; i++) {
        [rectangleHeights insertObject:[NSNumber numberWithFloat:prevMeterPlaceholderY] atIndex:i];
        prevMeterPlaceholderY -= meterPlaceholderHeight;
    }
    
    CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
    for (int i = 0; i < soundLevel; i++) {
        NSNumber *number = [rectangleHeights objectAtIndex:i];
        CGRect rectangle = CGRectMake(kMeterPlaceholderOriginX, [number floatValue], kMeterPlaceholderSideLength, kMeterPlaceholderSideLength);
        CGContextFillRect(context, rectangle);
    }
    
    CGContextSetRGBFillColor(context, 100.0f/255.0f, 100.0f/255.0f, 100.0f/255.0f, 1.f);
    for (int i = soundLevel; i < rectangleHeights.count; i++) {
        NSNumber *number = [rectangleHeights objectAtIndex:i];
        CGRect rectangle = CGRectMake(kMeterPlaceholderOriginX, [number floatValue], kMeterPlaceholderSideLength, kMeterPlaceholderSideLength);
        CGContextFillRect(context, rectangle);
    }
}

- (void)updateViewWithPeakPower:(CGFloat)peakPower averagePower:(CGFloat)averagePower
{
    if (self.recording) {
        self.peakSoundLevel = [self _getSoundLevelOfSound:peakPower];
        self.averageSoundLevel = [self _getSoundLevelOfSound:averagePower];
        [self setNeedsDisplay];
    }
}

- (int)_getSoundLevelOfSound:(CGFloat)sound
{
    NSNumber *index;
    if (sound < -50) {
        index = [NSNumber numberWithInt:0];
    } else if (sound >= -50 && sound < 0) {
        // according to apple doc, the decible value is between -160 and 0
        double peakPowerForChannel = (50 + sound) / 50.0 * 5;
        index = [NSNumber numberWithFloat:peakPowerForChannel];
    } else {
        index = [NSNumber numberWithInt:4];
    }
    return [index integerValue];
}

@end
