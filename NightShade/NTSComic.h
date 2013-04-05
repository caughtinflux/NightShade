//
//  NTSComic.h
//  NightShade
//
//  Created by Aditya KD on 04/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

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

+ (NSString *)pathToComicWithNumber:(NSNumber *)number;

// This method magically creates all properties except `image`.
// You have to call downloadImageWithCompletionHandler: for it to be downloaded.
- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

// Persistence
- (instancetype)initWithContentsOfFile:(NSString *)path;
- (void)saveToFile;

- (void)downloadImageWithCompletionHandler:(void (^) (UIImage *, NSError *))completionHandler;

@end
