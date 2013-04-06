//
//  IDZViewController.h
//  IDZAudoPlayer
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
#import <UIKit/UIKit.h>
#import "IDZAQAudioPlayer.h"

/**
 * @brief A quick and dirty screen for controlling and testing an IDZAudioPlayer.
 */
@interface IDZAudioPlayerViewController : UIViewController<IDZAudioPlayerDelegate>
/**
 * @brief Displays current playback time.
 */
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
/**
 * @brief Displays current audio device time.
 */
@property (weak, nonatomic) IBOutlet UILabel *deviceCurrentTimeLabel;
/**
 * @brief Displays source duration.
 */
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
/**
 * @brief Displays number of channels in source.
 */
@property (weak, nonatomic) IBOutlet UILabel *numberOfChannelsLabel;
/**
 * @brief Displays YES if the player is playing, NO otherwise.
 */
@property (weak, nonatomic) IBOutlet UILabel *playingLabel;
/**
 * @brief Slider label displaying current playback time.
 * @see currentTimeLabel
 */
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
/**
 * @brief Slider label displaying remaining playback time.
 */
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
/**
 * @brief Slider intended to allow user to seek in source.
 */
@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;
/**
 * @brief Button that invokes #play:
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/**
 * @brief Button that invokes #pause:
 */
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
/**
 * @brief Button that invokes #stop:
 */
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
/**
 * @brief Begins playback.
 */
- (IBAction)play:(id)sender;
/**
 * @brief Pauses playback.
 */
- (IBAction)pause:(id)sender;
/**
 * @brief Stops playback.
 */
- (IBAction)stop:(id)sender;
/**
 * @brief Updates the slider labels as the user drags its.
 */
- (IBAction)currentTimeSliderValueChanged:(id)sender;
/**
 * @brief Seeks when the user releases the slider.
 */
- (IBAction)currentTimeSliderTouchUpInside:(id)sender;


@end
