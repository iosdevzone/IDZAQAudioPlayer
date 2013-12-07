//
//  IDZAQAudioPlayer.m
//  IDZAQAudioPlayer
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
//
#import <AudioToolbox/AudioToolbox.h>

#import "IDZAQAudioPlayer.h"
#import "IDZAudioDecoder.h"
#import "IDZTrace.h"

/*
 * Apple uses 3 buffers in the AQPlayer example. We'll do the same.
 * See: http://developer.apple.com/library/ios/#samplecode/SpeakHere/Listings/Classes_AQPlayer_mm.html
 */
#define IDZ_BUFFER_COUNT 3


typedef enum IDZAudioPlayStateTag
{
    IDZAudioPlayerStateStopped,
    IDZAudioPlayerStatePrepared,
    IDZAudioPlayerStatePlaying,
    IDZAudioPlayerStatePaused,
    IDZAudioPlayerStateStopping
    
} IDZAudioPlayerState;

/**
 * @brief IDZAudioPlayer private internals.
 */
@interface IDZAQAudioPlayer ()
{
@private
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[IDZ_BUFFER_COUNT];
    BOOL mStopping;
    NSTimeInterval mQueueStartTime;
}
/**
 * @brief Queries the value of the Audio Queue's kAudioQueueProperty_IsRunning property.
 */
- (UInt32)queryIsRunning;
/**
 * @brief Reads data from the audio source and enqueues it on the audio queue.
 */
- (void)readBuffer:(AudioQueueBufferRef)buffer;
/**
 * @brief Stops playback
 * @param immediate if YES playback stops immediately, otherwise playback stops after all enqueued buffers 
 * have finished playing.
 */
- (BOOL)stop:(BOOL)immediate;
/**
 * @brief YES if the player is playing, NO otherwise.
 */
@property (readwrite, getter=isPlaying) BOOL playing;
/**
 * @brief The decoder associated with this player.
 */
@property (readonly, strong) id<IDZAudioDecoder> decoder;
/**
 * @brief The current player state.
 */
@property (nonatomic, assign) IDZAudioPlayerState state;
@end


@implementation IDZAQAudioPlayer
@dynamic currentTime;
@dynamic numberOfChannels;
@dynamic duration;
@synthesize playing = mPlaying;
@synthesize decoder = mDecoder;
@synthesize state = mState;

// MARK: - Static Callbacks
static void IDZOutputCallback(void *                  inUserData,
                              AudioQueueRef           inAQ,
                              AudioQueueBufferRef     inCompleteAQBuffer)
{
    IDZAQAudioPlayer* pPlayer = (__bridge IDZAQAudioPlayer*)inUserData;
    [pPlayer readBuffer:inCompleteAQBuffer];
}

static void IDZPropertyListener(void* inUserData,
                                AudioQueueRef inAQ,
                                AudioQueuePropertyID inID)
{
    IDZAQAudioPlayer* pPlayer = (__bridge IDZAQAudioPlayer*)inUserData;
    if(inID == kAudioQueueProperty_IsRunning)
    {
        UInt32 isRunning = [pPlayer queryIsRunning];
        NSLog(@"isRunning = %u", (unsigned int)isRunning);
        BOOL bDidFinish = (pPlayer.playing && !isRunning);
        pPlayer.playing = isRunning ? YES : NO;
        if(bDidFinish)
        {
            [pPlayer.delegate audioPlayerDidFinishPlaying:pPlayer
                                              successfully:YES];
            /*
             * To match AVPlayer's behavior we need to reset the file.
             */
            pPlayer.currentTime = 0;
        }
        if(!isRunning)
            pPlayer.state = IDZAudioPlayerStateStopped;
    }
    
}


- (id)initWithDecoder:(id<IDZAudioDecoder>)decoder error:(NSError *__autoreleasing *)error  
{
    NSParameterAssert(decoder);
    if(self = [super init])
    {
        mDecoder = decoder;
        AudioStreamBasicDescription dataFormat = decoder.dataFormat;
        OSStatus status = AudioQueueNewOutput(&dataFormat, IDZOutputCallback,
                                              (__bridge void*)self,
                                              CFRunLoopGetCurrent(),
                                              kCFRunLoopCommonModes,
                                              0,
                                              &mQueue);
        NSAssert(status == noErr, @"Audio queue creation was successful.");
        AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0);
        status = AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning,
                                               IDZPropertyListener, (__bridge void*)self);
        
        for(int i = 0; i < IDZ_BUFFER_COUNT; ++i)
        {
            UInt32 bufferSize = 128 * 1024;
            status = AudioQueueAllocateBuffer(mQueue, bufferSize, &mBuffers[i]);
            if(status != noErr)
            {
                if(*error)
                {
                    *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
                }
                AudioQueueDispose(mQueue, true);
                mQueue = 0;
                return nil;
            }
            
        }
    }
    mState = IDZAudioPlayerStateStopped;
    mQueueStartTime = 0.0;
    return self;
}

- (BOOL)prepareToPlay
{
    for(int i = 0; i < IDZ_BUFFER_COUNT; ++i)
    {
        [self readBuffer:mBuffers[i]];
    }
    self.state = IDZAudioPlayerStatePrepared;
    return YES;
}
- (BOOL)play
{
    switch(self.state)
    {
        case IDZAudioPlayerStatePlaying:
            return NO;
        case IDZAudioPlayerStatePaused:
        case IDZAudioPlayerStatePrepared:
            break;
        default:
            [self prepareToPlay];
    }
    OSStatus osStatus = AudioQueueStart(mQueue, NULL);
    NSAssert(osStatus == noErr, @"AudioQueueStart failed");
    self.state = IDZAudioPlayerStatePlaying;
    self.playing = YES;
    return (osStatus == noErr);
    
}
- (BOOL)pause
{
    if(self.state != IDZAudioPlayerStatePlaying) return NO;
    OSStatus osStatus = AudioQueuePause(mQueue);
    NSAssert(osStatus == noErr, @"AudioQueuePause failed");
    self.state = IDZAudioPlayerStatePaused;
    return (osStatus == noErr);
    
    
}

- (BOOL)stop
{
    return [self stop:YES];
}

- (BOOL)stop:(BOOL)immediate
{
    self.state = IDZAudioPlayerStateStopping;
    OSStatus osStatus = AudioQueueStop(mQueue, immediate);

    NSAssert(osStatus == noErr, @"AudioQueueStop failed");
    return (osStatus == noErr);    
}

- (void)readBuffer:(AudioQueueBufferRef)buffer
{
    if(self.state == IDZAudioPlayerStateStopping)
        return;
    
    NSAssert(self.decoder, @"self.decoder is valid.");
    if([self.decoder readBuffer:buffer])
    {
        OSStatus status = AudioQueueEnqueueBuffer(mQueue, buffer, 0, 0);
        if(status != noErr)
        {
            NSLog(@"Error: %s status=%d", __PRETTY_FUNCTION__, (int)status);
        }
    }
    else
    {
        /*
         * Signal to the audio queue that we have run out of data,
         * but set the immediate flag to false so that playback of
         * currently enqueued buffers completes.
         */
        self.state = IDZAudioPlayerStateStopping;
        Boolean immediate = false;
        AudioQueueStop(mQueue, immediate);
    }
}

// MARK: - Properties

- (UInt32)queryIsRunning
{
    UInt32 oRunning = 0;
    UInt32 ioSize = sizeof(oRunning);
    OSStatus result = AudioQueueGetProperty(mQueue, kAudioQueueProperty_IsRunning, &oRunning, &ioSize);
    return oRunning;
}
- (NSTimeInterval)duration
{
    NSTimeInterval duration = mDecoder.duration;
    return duration;
}

- (NSTimeInterval)currentTime
{
    
    AudioTimeStamp outTimeStamp;
    Boolean outTimelineDiscontinuity;
    /*
     * can fail with -66678
     */
    OSStatus status = AudioQueueGetCurrentTime(mQueue, NULL, &outTimeStamp, &outTimelineDiscontinuity);
    NSTimeInterval currentTime;
    switch(status)
    {
        case noErr:
            currentTime = (NSTimeInterval)outTimeStamp.mSampleTime/self.decoder.dataFormat.mSampleRate + mQueueStartTime;
            break;
        case kAudioQueueErr_InvalidRunState:
            currentTime = 0.0;
            break;
        default:
            currentTime = -1.0;
            
    }
    return mQueueStartTime + currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    IDZAudioPlayerState previousState = self.state;
    switch(self.state)
    {
        case IDZAudioPlayerStatePlaying:
            [self stop:YES];
            break;
        default:
            break;
    }
    [self.decoder seekToTime:currentTime error:nil];
    mQueueStartTime = currentTime;
    switch(previousState)
    {
        case IDZAudioPlayerStatePrepared:
            [self prepareToPlay];
            break;
        case IDZAudioPlayerStatePlaying:
            [self play];
            break;
        default:
            break;
    }
}

- (NSUInteger)numberOfChannels
{
    return self.decoder.dataFormat.mChannelsPerFrame;
}


- (void)setState:(IDZAudioPlayerState)state
{
    switch(state)
    {
        case IDZAudioPlayerStatePaused:
            NSLog(@"IDZAudioPlayerStatePaused");
            break;
        case IDZAudioPlayerStatePlaying:
            NSLog(@"IDZAudioPlayerStatePlaying");
            break;
        case IDZAudioPlayerStatePrepared:
            NSLog(@"IDZAudioPlayerStatePrepared");
            break;
        case IDZAudioPlayerStateStopped:
            NSLog(@"IDZAudioPlayerStateStopped");
            break;
        case IDZAudioPlayerStateStopping:
            NSLog(@"IDZAudioPlayerStateStopping");
            break;
    }
    mState = state;
}
@end
