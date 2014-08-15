Multistroke-Gesture-Recognizer-iOS-IET-DAVV
===========================================
# Overview

An Alphabate Recognizer for iOS Platform using $N Algorithum.This library make use of iOS implementation of $N algorithum provided by [Brit Gardner](https://github.com/britg/MultistrokeGestureRecognizer-iOS).


# N Dollar Recognizer

Anthony, L. and Wobbrock, J.O. (2010). [A lightweight multistroke recognizer for user interface prototypes](http://faculty.washington.edu/wobbrock/pubs/gi-10.2.pdf). Proceedings of Graphics Interface (GI '10). Ottawa, Ontario (May 31-June 2, 2010). Toronto, Ontario: Canadian Information Processing Society, pp. 245-252.

# Detecting Glyphs

A Glyph is a user-defined set of Strokes, which are in turn just an array of points. When a Glyph is initialized, it first permutes through all the possible combinations of Stroke directions/order necessary to recreate itself. It also resamples and resizes itslef into a bounding box. Finally, a Glyph creates unistrokes (Templates) from all the calculated multistrokes.

The Detector collects user input (an array of points) and triggers a comparison of the input against all of the Glyph Templates. Each Template is given a score, and the Template with the highest score is considered the match. The Glyph that the Template belongs to is announced to the Delegate.

# Creating Glyphs

A Glyph can either be defined manually by defining its Strokes and initializing a Glyph with those Strokes. Or, a newly created Glyph can be fed user input and create itself when ready. 

# Guided By 
- [Mr. Pratosh Bansal](https://github.com/pratoshbansal) Professor,Department of Information Technology, IET-DAVV, Indore.
- [Mr. Awanish Tiwari](https://github.com/awanish-tiwari) Technical Architect, Newput Infotech, Indore.

# Acknowledgement

This work is done as a part of my ME thesis work from IET-DAVV, Indore for project entitled "Building A Personal Handwriting Recognizer on an iOS device and Adding New Gestures for Handwriting Recognition" in guidance of Mr. Pratosh Bansal @pratoshbansal ,Professor,Department of Information Technology, IET-DAVV, Indore and Industrial guide Mr Awanish Tiwari@awanish-tiwari, Technical Architect, Newput Infotech, Indore.


# License

Copyright (c) 2014, Prateek Pradhan
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the {organization} nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
