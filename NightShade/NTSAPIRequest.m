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

- (void)getLatestComicWithCompletion:(NTSCompletionHandler)handler
{
	[self getComicForNumber:@0 withCompletion:handler];
}

- (void)getComicForNumber:(NSNumber *)comicNumber withCompletion:(NTSCompletionHandler)handler
{
    NSAssert((handler != nil), @"A completion handler must be called into NTSAPIRequest calls!");
    
	NSString *feedURLString = [NSString stringWithFormat:@"http://xkcd.com/%i/info.0.json", [comicNumber integerValue]];
	NSURL *feedURL = [NSURL URLWithString:([comicNumber isEqualToNumber:@0] ? @"http://xkcd.com/info.0.json" : feedURLString)];
	NSURLRequest *feedURLRequest = [[NSURLRequest alloc] initWithURL:feedURL];
	
	[NSURLConnection sendAsynchronousRequest:feedURLRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NTSComic *comic = nil;
		
		if (!error) {
			NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			comic = [[NTSComic alloc] initWithJSONDictionary:dictionary];
		}
		handler(comic, error);
	}];
}

@end
