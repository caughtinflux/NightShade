/*
 NTSAPIRequest.m
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

#import "NTSAPIRequest.h"
#import "NTSComic.h"

@implementation NTSAPIRequest

- (void)downloadLatestComicWithCompletion:(NTSCompletionHandler)handler
{
	[self downloadComicWithNumber:@0 withCompletion:handler];
}

- (void)downloadComicWithNumber:(NSNumber *)comicNumber withCompletion:(NTSCompletionHandler)handler
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
