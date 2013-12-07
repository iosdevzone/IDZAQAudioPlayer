//
//  IDZOggVorbisFileDecoder.m
//  IDZAudioDecoder
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
#import <Vorbis/vorbisfile.h>

#import "IDZOggVorbisFileDecoder.h"
#import "IDZTrace.h"

#define IDZ_BITS_PER_BYTE 8
#define IDZ_BYTES_TO_BITS(bytes) ((bytes) * IDZ_BITS_PER_BYTE)
#define IDZ_OGG_VORBIS_WORDSIZE 2

/**
 * @brief IDZOggVorbisFileDecoder private internals.
 */
@interface IDZOggVorbisFileDecoder ()
{
@private
    FILE* mpFile;
    OggVorbis_File mOggVorbisFile;
}

@end


@implementation IDZOggVorbisFileDecoder
@synthesize dataFormat = mDataFormat;

- (id)initWithContentsOfURL:(NSURL*)url error:(NSError *__autoreleasing *)error
{
    NSParameterAssert([url isFileURL]);
    if(self = [super init])
    {
        NSString* path = [url path];
        mpFile = fopen([path UTF8String], "r");
        NSAssert(mpFile, @"fopen succeeded.");
        int iReturn = ov_open_callbacks(mpFile, &mOggVorbisFile, NULL, 0, OV_CALLBACKS_NOCLOSE);
        NSAssert(iReturn >= 0, @"ov_open_callbacks succeeded.");
        vorbis_info* pInfo = ov_info(&mOggVorbisFile, -1);
        int bytesPerChannel = IDZ_OGG_VORBIS_WORDSIZE;
        FillOutASBDForLPCM(mDataFormat,
                           (Float64)pInfo->rate, // sample rate (fps)
                           (UInt32)pInfo->channels, // channels per frame
                           (UInt32)IDZ_BYTES_TO_BITS(bytesPerChannel), // valid bits per channel
                           (UInt32)IDZ_BYTES_TO_BITS(bytesPerChannel), // total bits per channel
                           false, // isFloat
                           false); // isBigEndian
        
    }
    return self;
}

- (void)dealloc
{
    ov_clear(&mOggVorbisFile);
    if(mpFile)
    {
        fclose(mpFile);
        mpFile = NULL;
    }
}

- (BOOL)readBuffer:(AudioQueueBufferRef)pBuffer
{
    IDZTrace();
    int bigEndian = 0;
    int wordSize = IDZ_OGG_VORBIS_WORDSIZE;
    int signedSamples = 1;
    int currentSection = -1;
    
    /* See: http://xiph.org/vorbis/doc/vorbisfile/ov_read.html */
    UInt32 nTotalBytesRead = 0;
    long nBytesRead = 0;
    do
    {
        nBytesRead = ov_read(&mOggVorbisFile,
                             (char*)pBuffer->mAudioData + nTotalBytesRead,
                             (int)(pBuffer->mAudioDataBytesCapacity - nTotalBytesRead),
                             bigEndian, wordSize,
                             signedSamples, &currentSection);
        if(nBytesRead  <= 0)
            break;
        nTotalBytesRead += nBytesRead;
    } while(nTotalBytesRead < pBuffer->mAudioDataBytesCapacity);
    if(nTotalBytesRead == 0)
        return NO;
    if(nBytesRead < 0)
    {
        return NO;
    }
    pBuffer->mAudioDataByteSize = nTotalBytesRead;
    pBuffer->mPacketDescriptionCount = 0;
    return YES;
    
}

- (BOOL)seekToTime:(NSTimeInterval)time error:(NSError**)error
{
    /* 
     * Possible errors are OV_ENOSEEK, OV_EINVAL, OV_EREAD, OV_EFAULT, OV_EBADLINK
     * See: http://xiph.org/vorbis/doc/vorbisfile/ov_time_seek.html
     */
    int iResult = ov_time_seek(&mOggVorbisFile, time);
    NSLog(@"ov_time_seek(%g) = %d", time, iResult);
    return (iResult == 0);
}

// MARK: - Dynamic Properties
- (NSTimeInterval)duration
{
    double duration = ov_time_total(&mOggVorbisFile, -1);
    return (NSTimeInterval)duration;
}

@end
