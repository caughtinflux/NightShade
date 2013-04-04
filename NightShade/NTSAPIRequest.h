//
//  NTSAPIRequest.h
//  NightShade
//
//  Created by Aditya KD on 04/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTSComic;

typedef void (^NTSCompletionHandler)(NTSComic *, NSError *);

@interface NTSAPIRequest : NSObject

- (void)getLatestComicWithCompletionHandler:(NTSCompletionHandler)handler;
- (void)getComicForNumber:(NSNumber *)comicNumber withCompletionHandler:(NTSCompletionHandler)handler;

@end
