//
//  NTSComic.m
//  NightShade
//
//  Created by Aditya KD on 04/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import "NTSComic.h"

@implementation NTSComic

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Title: %@ creation date: %@, comic number: %@, image URL: %@", [super description], _title, _dateString, _comicNumber, _imageURL];
}

@end
