//
//  NTSAPIRequest.m
//  NightShade
//
//  Created by Aditya KD on 04/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import "NTSAPIRequest.h"
#import "NTSComic.h"

@implementation NTSAPIRequest

- (void)getLatestComicWithCompletionHandler:(NTSCompletionHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _downloadComicAtURL:[NSURL URLWithString:@"http://xkcd.com/info.0.json"] handler:handler];
    });
}

- (void)getComicForNumber:(NSNumber *)comicNumber withCompletionHandler:(NTSCompletionHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *link = [NSString stringWithFormat:@"http://xkcd.com/%i/info.0.json", [comicNumber integerValue]];
        
        [self _downloadComicAtURL:[NSURL URLWithString:link] handler:handler];
    });
}

- (void)_downloadComicAtURL:(NSURL *)URL handler:(NTSCompletionHandler)handler
{
    NSAssert((handler != nil), @"NTSAPIRequest calls must have a completion handler!");
    
    NTSComic *comic = nil;
    NSError *error = nil;
    
    NSData *rawData = [NSData dataWithContentsOfURL:URL options:NSDataReadingMappedIfSafe error:&error];
    if (!error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:rawData options:kNilOptions error:&error];
        // reuse the same NSError object.
        if (!error) {
            comic = [[NTSComic alloc] initWithJSONDictionary:dictionary];
        }
    }
    handler(comic, error);
}

@end
