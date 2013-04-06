//
//  IDZAQAudioPlayer.h
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
#import <Foundation/Foundation.h>
#import "IDZAudioPlayer.h"
#import "IDZAudioDecoder.h"
/**
 * @brief An Audio Queue based audio player conforming to IDZAudioPlayer.
 *
 * This class plays audio data supplied by an object conforming to 
 * the IDZAudioDecoder protocol, for example, the IDZOggVorbisFileDecoder
 * class can be used to play Ogg Vorbis files.
 */
@interface IDZAQAudioPlayer : NSObject<IDZAudioPlayer>
/**
 * @brief Initialized the receiver to play audio from a specified decoder.
 * 
 * @param decoder the decoder to obtain audio data from, must no be nil.
 * @param error will receive error information if not nil.
 * @return a pointer to the receiver or nil if an error occurs.
 */
- (id)initWithDecoder:(id<IDZAudioDecoder>)decoder error:(NSError**)error;
/**
 * @brief Delegate notified when playback ends.
 */
@property(assign) id<IDZAudioPlayerDelegate> delegate;
/**
 * @brief The current audio device time.
 */
@property(readonly) NSTimeInterval deviceCurrentTime;

@end

