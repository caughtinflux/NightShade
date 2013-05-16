/*
 NTSComic.m
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

#import "NTSComic.h"


static NSString * const NTSComicTitleKey      = @"NTSComicTitle";
static NSString * const NTSComicSafeTitleKey  = @"NTSComicSafeTitle";
static NSString * const NTSComicTranscriptKey = @"NTSComicTranscript";
static NSString * const NTSComicAltKey        = @"NTSComicAlt";
static NSString * const NTSComicLinkKey       = @"NTSComicLink";
static NSString * const NTSComicNewsKey       = @"NTSComicNews";
static NSString * const NTSComicDateStringKey = @"NTSComicDateString";
static NSString * const NTSComicNumberKey     = @"NTSComicNumber";
static NSString * const NTSComicImageURLKey   = @"NTSComicImageURL";
static NSString * const NTSComicImageKey      = @"NTSComicImage";

@implementation NTSComic {}

#pragma mark - Convenience
+ (instancetype)comicWithJSONDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithJSONDictionary:dictionary];
}

+ (instancetype)comicWithContentsOfFile:(NSString *)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

#pragma mark - Designated Initializer(s)
- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        _title       = [dictionary[@"title"] copy];
        _safeTitle   = [dictionary[@"safe_title"] copy];
        _transcript  = [dictionary[@"transcript"] copy];
        _alt         = [dictionary[@"alt"] copy];
        _link        = [dictionary[@"link"] copy];
        _news        = [dictionary[@"news"] copy];
        _dateString  = [NSString stringWithFormat:@"%@-%@-%@", dictionary[@"day"], dictionary[@"month"], dictionary[@"year"]];
        _comicNumber = [dictionary[@"num"] copy];
        _imageURL    = [[NSURL URLWithString:dictionary[@"img"]] copy];
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)path
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

#pragma mark - NSCoding Implementation
- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        _title       = [[decoder decodeObjectForKey:NTSComicTitleKey] copy];
        _safeTitle   = [[decoder decodeObjectForKey:NTSComicSafeTitleKey] copy];
        _transcript  = [[decoder decodeObjectForKey:NTSComicTranscriptKey] copy];
        _alt         = [[decoder decodeObjectForKey:NTSComicAltKey] copy];
        _link        = [[decoder decodeObjectForKey:NTSComicLinkKey] copy];
        _news        = [[decoder decodeObjectForKey:NTSComicNewsKey] copy];
        _dateString  = [[decoder decodeObjectForKey:NTSComicDateStringKey] copy];
        _comicNumber = [[decoder decodeObjectForKey:NTSComicNumberKey] copy];
        _imageURL    = [[decoder decodeObjectForKey:NTSComicImageURLKey] copy];
        _image       = [[decoder decodeObjectForKey:NTSComicImageKey] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_title       forKey:NTSComicTitleKey];
    [coder encodeObject:_safeTitle   forKey:NTSComicSafeTitleKey];
    [coder encodeObject:_transcript  forKey:NTSComicTranscriptKey];
    [coder encodeObject:_alt         forKey:NTSComicAltKey];
    [coder encodeObject:_link        forKey:NTSComicLinkKey];
    [coder encodeObject:_news        forKey:NTSComicNewsKey];
    [coder encodeObject:_dateString  forKey:NTSComicDateStringKey];
    [coder encodeObject:_comicNumber forKey:NTSComicNumberKey];
    [coder encodeObject:_imageURL    forKey:NTSComicImageURLKey];
    [coder encodeObject:_image       forKey:NTSComicImageKey];
}

- (void)saveToFileAtPath:(NSString *)path
{
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (void)downloadImageWithCompletionHandler:(void (^) (NSError *))completionHandler
{
    NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:_imageURL];
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *reponse, NSData *receivedData, NSError *error) {
        
        _image = [[UIImage imageWithData:receivedData] copy];
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

#pragma mark -
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ title: %@, creation date: %@, comic number: %@, image URL: %@ image: %@", [super description], _title, _dateString, _comicNumber, _imageURL, _image];
}

@end
