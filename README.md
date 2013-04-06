IDZAQAudioPlayer
================

An easy to use audio player that uses Audio Queues.

This is unfinished source code for an upcoming tutorial on my blog. Please note the following:
* Seeking is only partially implemented
* Error handling is incomplete or non-existent.

Structure
---------

The protocol IDZAudioDecoder defines the methods and properties that are required to be an IDZAudioDecoder.
The class IDZOggVorbisFileDecoder is an audio decoder that conforms to the IDZAudioDecoder protocol. 

The class IDZAQAudioPlayer can play, using Audio Queues, the decoded audio from an IDZAudioDecoder.

The protocol IDZAudioPlayer defines the methods and properties that are required to be an IDZAudioPlayer. These are
designed to be as close as possible to the methods provided by Apple's AVAudioPlayer class.

The class IDZAudioPlayerViewController knows how to control an audio player that conforms to the IDZAudioPlayer protocol,
so, for example, you could trivially subclass AVAudioPlayer, adopting the IDZAudioPlayer protocol and use the same view
controller to control it. The IDZAudioPlayerViewController is not intended to be pretty or a great example of UI design; 
it is intended soley as a demonstration and test interface for IDZAudioPlayers!!!

Licenses
========

iOSDeveloperZone.com Code
-------------------------

All the iOSDeveloperZone.com code in this repository is covered by an MIT license. This license is reproduced at the top of each source file.


Xiph.org Foundation Code
------------------------

This project uses libogg and libvorbis:

Copyright (c) 2002-2008 Xiph.org Foundation

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

- Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

- Neither the name of the Xiph.org Foundation nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Wikipedia Commons
-----------------

This repository contains an excerpt of http://commons.wikimedia.org/wiki/File:Rondo_Alla_Turka.ogg


