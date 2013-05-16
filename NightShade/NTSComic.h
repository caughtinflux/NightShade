/*
 NTSComic.h
 NightShade
 Created by Aditya KD on 04/04/13.
 
 Copyright 2013 ProtoFlux
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

@interface NTSComic : NSObject <NSCoding>

@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *safeTitle;
@property(nonatomic, readonly) NSString *transcript;
@property(nonatomic, readonly) NSString *alt;
@property(nonatomic, readonly) NSString *link;
@property(nonatomic, readonly) NSString *news;

@property(nonatomic, readonly) NSString *dateString;
@property(nonatomic, readonly) NSNumber *comicNumber;

@property(nonatomic, readonly) NSURL    *imageURL;
@property(nonatomic, readonly) UIImage  *image;

// These methods would return an autoreleased instance in a non-ARC world, but now they just do the same as the instance methods.
+ (instancetype)comicWithJSONDictionary:(NSDictionary *)dictionary;
+ (instancetype)comicWithContentsOfFile:(NSString *)path;


// This method magically creates all properties except `image`.
// You have to call downloadImageWithCompletionHandler: for it to be downloaded.
- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

// Persistence
- (instancetype)initWithContentsOfFile:(NSString *)path;
- (void)saveToFileAtPath:(NSString *)path;

// An NSError object is passed in as an argument if anything goes wrong. The image can be accessed from the receiver's `image` property
- (void)downloadImageWithCompletionHandler:(void (^) (NSError *))completionHandler;

@end
