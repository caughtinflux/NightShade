//
//  NTSComic.m
//  NightShade
//
//  Created by Aditya KD on 04/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

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

+ (NSString *)pathToComicWithNumber:(NSNumber *)number
{
    NSString *documentsDirectoryPath = (NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0];
    return [[documentsDirectoryPath stringByAppendingString:@"/"] stringByAppendingString:[number stringValue]];
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


#pragma mark -
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ title: %@ creation date: %@, comic number: %@, image URL: %@", [super description], _title, _dateString, _comicNumber, _imageURL];
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
        _comicNumber = [[decoder decodeObjectForKey:NTSComicDateStringKey] copy];
        _imageURL    = [[decoder decodeObjectForKey:NTSComicImageURLKey] copy];
        _image       = [[decoder decodeObjectForKey:NTSComicImageKey] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_title forKey:NTSComicTitleKey];
    [coder encodeObject:_safeTitle forKey:NTSComicSafeTitleKey];
    [coder encodeObject:_transcript forKey:NTSComicTranscriptKey];
    [coder encodeObject:_alt forKey:NTSComicAltKey];
    [coder encodeObject:_link forKey:NTSComicLinkKey];
    [coder encodeObject:_news forKey:NTSComicNewsKey];
    [coder encodeObject:_dateString forKey:NTSComicDateStringKey];
    [coder encodeObject:_comicNumber forKey:NTSComicNumberKey];
    [coder encodeObject:_imageURL forKey:NTSComicImageURLKey];
    [coder encodeObject:_image forKey:NTSComicImageKey];
}

- (void)saveToFile
{
    NSString *path = [NTSComic pathToComicWithNumber:_comicNumber];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (void)downloadImageWithCompletionHandler:(void (^) (UIImage *, NSError *))completionHandler
{
    NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:_imageURL];
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *reponse, NSData *receivedData, NSError *error) {
        UIImage *image = [UIImage imageWithData:receivedData];
        
        _image = [image copy];
        
        if (completionHandler) {
            completionHandler(image, error);
        }
    }];
}

@end
