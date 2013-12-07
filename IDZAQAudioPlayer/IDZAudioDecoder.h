//
//  IDZAudioDecoder.h
//  IDZAudioPlayerDevelopment
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
/**
 * @file
 * @brief The required interface of an audio decoder.
 */
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
/**
 * @brief Required audio decoder methods and properties
 *
 * The IDZAQAudioPlayer can playback audio from a decoder that
 * implements these methods. IDZOggVorbisFileDecoder is a concrete 
 * implementation that plays back Ogg Vorbis files.
 *
 * @see IDZOggVorbisFileDecoder
 */
@protocol IDZAudioDecoder <NSObject>
@required
/**
 * @brief Description of the audio format produced by this decoder.
 *
 * This must be one of the audio format supported by iOS.
 */
@property(readonly) AudioStreamBasicDescription dataFormat;
/**
 * @brief The duration of the source in seconds.
 */
@property(readonly) NSTimeInterval duration;
/**
 * @brief Fills an audio buffer with decoded audio data from the source.
 */
- (BOOL)readBuffer:(AudioQueueBufferRef)buffer;
/**
 * @brief Seeks to a specified time in an audio source.
 *
 * @param timeInterval the time in seconds from the start of the source.
 * @param error if not nil will receive error information in case of an error.
 * @return YES if successful, NO if an error occurs.
 */
- (BOOL)seekToTime:(NSTimeInterval)timeInterval error:(NSError*__autoreleasing*)error;

@end
