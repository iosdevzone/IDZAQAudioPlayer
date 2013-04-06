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
@property(readonly) AudioStreamBasicDescription dataFormat;
@property(readonly) NSTimeInterval duration;

- (BOOL)readBuffer:(AudioQueueBufferRef)buffer;
- (BOOL)seekToTime:(NSTimeInterval)timeInterval error:(NSError*)error;

@end
