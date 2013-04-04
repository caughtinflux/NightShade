//
//  NTSComic.h
//  NightShade
//
//  Created by Aditya KD on 04/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NTSComic : NSObject

@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *safeTitle;
@property(nonatomic, readonly) NSString *transcript;
@property(nonatomic, readonly) NSString *alt;
@property(nonatomic, readonly) NSString *link;
@property(nonatomic, readonly) NSString *news;

@property(nonatomic, readonly) NSString *dateString;
@property(nonatomic, readonly) NSNumber *comicNumber;

@property(nonatomic, readonly) NSURL    *imageURL;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
