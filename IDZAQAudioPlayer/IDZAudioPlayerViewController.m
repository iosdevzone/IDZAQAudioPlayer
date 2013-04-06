//
//  IDZViewController.m
//  IDZAudoPlayerTutorial
//
// Copyright (c) 2013 iOSDeveloperZone.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
#import "IDZAudioPlayerViewController.h"
#import "IDZTrace.h"
#import "IDZOggVorbisFileDecoder.h"



/**
 * @brief IDZAudioPlayerViewController private internals.
 */
@interface IDZAudioPlayerViewController ()
/**
 * @brief The audio player being controlled.
 */
@property (nonatomic, strong) id<IDZAudioPlayer> player;
/**
 * @brief The display update timer.
 */
@property (nonatomic, strong) NSTimer* timer;
/**
 * @brief Updates the display to reflact the current player state.
 */
- (void)updateDisplay;
/**
 * @brief Updates the slider labels based on the slider's current value.
 */
- (void)updateSliderLabels;

//- (void)audioPlayerDidFinishPlaying:(id<IDZAudioPlayer>)player
//                       successfully:(BOOL)flag;
//- (void)audioPlayerDecodeErrorDidOccur:(id<IDZAudioPlayer>)player
//                                 error:(NSError *)error;

@end

@implementation IDZAudioPlayerViewController
@synthesize currentTimeLabel = mCurrentTimeLabel;
@synthesize deviceCurrentTimeLabel = mDeviceCurrentTimeLabel;
@synthesize durationLabel = mDurationLabel;
@synthesize numberOfChannelsLabel = mNumberOfChannels;
@synthesize playingLabel = mPlayingLabel;
@synthesize elapsedTimeLabel = mElapsedTimeLabel;
@synthesize remainingTimeLabel = mRemainingTimeLabel;
@synthesize currentTimeSlider = mCurrentTimeSlider;
@synthesize playButton = mPlayingButton;
@synthesize pauseButton = mPauseButton;
@synthesize stopButton = mStopButton;
@synthesize player = mPlayer;
@synthesize timer = mTimer;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.  

    NSError* error = nil;
#if 1 // This plays the ogg file
    NSURL* oggUrl = [[NSBundle mainBundle] URLForResource:@"Rondo_Alla_Turka" withExtension:@".ogg"];
    IDZOggVorbisFileDecoder* decoder = [[IDZOggVorbisFileDecoder alloc] initWithContentsOfURL:oggUrl error:&error];
    NSLog(@"Ogg Vorbis file duration is %g", decoder.duration);
    self.player = [[IDZAQAudioPlayer alloc] initWithDecoder:decoder error:nil];
#else
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Rondo_Alla_Turka_Short" withExtension:@"aiff"];
    NSAssert(url, @"URL is valid.");
    self.player = [[IDZAVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
#endif
    if(!self.player)
    {
        NSLog(@"Error creating player: %@", error);
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
    // Fill in the labels that do not change
    self.durationLabel.text = [NSString stringWithFormat:@"%.02fs",self.player.duration];
    self.numberOfChannelsLabel.text = [NSString stringWithFormat:@"%d", self.player.numberOfChannels];
    self.currentTimeSlider.minimumValue = 0.0f;
    self.currentTimeSlider.maximumValue = self.player.duration;
    [self updateDisplay];
}

- (void)viewDidUnload
{
    [self setPauseButton:nil];
    [self setPlayButton:nil];
    [self setStopButton:nil];
    [self setCurrentTimeLabel:nil];
    [self setDeviceCurrentTimeLabel:nil];
    [self setDurationLabel:nil];
    [self setNumberOfChannelsLabel:nil];
    [self setPlayingLabel:nil];
    [self setElapsedTimeLabel:nil];
    [self setRemainingTimeLabel:nil];
    [self setCurrentTimeSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)play:(id)sender {
    IDZTrace();
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [self.player play];
                  
}

- (IBAction)pause:(id)sender {
    IDZTrace();
    [self.player pause];
    [self stopTimer];
    [self updateDisplay];
}

- (IBAction)stop:(id)sender {
    IDZTrace();
    [self.player stop];
    [self stopTimer];
    self.player.currentTime = 0;
    //[self.player prepareToPlay];
    [self updateDisplay];
}

- (IBAction)currentTimeSliderValueChanged:(id)sender
{
    if(self.timer)
        [self stopTimer];
    [self updateSliderLabels];
    
}

- (IBAction)currentTimeSliderTouchUpInside:(id)sender
{
    float value = self.currentTimeSlider.value;
    self.player.currentTime = value;
}

#pragma mark - Display Update
- (void)updateDisplay
{
    NSTimeInterval currentTime = self.player.currentTime;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.currentTimeSlider.value = currentTime;
    [self updateSliderLabels];
    
    self.currentTimeLabel.text = currentTimeString;
    self.playingLabel.text = self.player.playing ? @"YES" : @"NO";
    self.deviceCurrentTimeLabel.text = [NSString stringWithFormat:@"%.02f", self.player.deviceCurrentTime];
}

- (void)updateSliderLabels
{
    NSTimeInterval currentTime = self.currentTimeSlider.value;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.elapsedTimeLabel.text =  currentTimeString;
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"%.02f", self.player.duration - currentTime];
}

#pragma mark - Timer
- (void)timerFired:(NSTimer*)timer
{
    IDZTrace();
    [self updateDisplay];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self updateDisplay];
}

#pragma mark - IDZAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(id<IDZAudioPlayer>)player successfully:(BOOL)flag
{
    NSLog(@"%s successfully=%@", __PRETTY_FUNCTION__, flag ? @"YES"  : @"NO");
    [self stopTimer];
    [self updateDisplay];
}

- (void)audioPlayerDecodeErrorDidOccur:(id<IDZAudioPlayer>)player error:(NSError *)error
{
    NSLog(@"%s error=%@", __PRETTY_FUNCTION__, error);
    [self stopTimer];
    [self updateDisplay];
}

@end
