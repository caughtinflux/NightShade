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

@interface NTSAPIRequest ()
+ (NSURLRequest *)_URLRequestForComicNumber:(NSNumber *)comicNumber;
@end

@implementation NTSAPIRequest

+ (void)downloadLatestComicWithImage:(BOOL)getImage completion:(NTSCompletionHandler)handler;
{
	[self downloadComicWithNumber:@0 getImage:getImage completion:handler];
}

+ (void)downloadComicWithNumber:(NSNumber *)comicNumber getImage:(BOOL)getImage completion:(NTSCompletionHandler)handler;
{
    NSAssert((handler != nil), @"A completion handler must be passed into NTSAPIRequest calls!");
    
	[NSURLConnection sendAsynchronousRequest:[self _URLRequestForComicNumber:comicNumber] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		if (error) {
            NSLog(@"Error downloading comic data. %i : %@", error.code, error.localizedDescription);
            handler(nil, error);
            return;
        }
        
        // Since the handler is called on the current queue, create and parse the data received in a background thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *jsonError;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (jsonError) {
                handler(nil, jsonError);
                return;
            }
            
            NTSComic *comic = [NTSComic comicWithJSONDictionary:dictionary];
            
            if (getImage) {
                [comic downloadImageWithCompletionHandler:^(NSError *imgError) {
                    handler(comic, imgError);
                }];
            }
        });
	}];
}

+ (NSURLRequest *)_URLRequestForComicNumber:(NSNumber *)comicNumber
{
    NSString *feedURLString = [NSString stringWithFormat:@"http://xkcd.com/%i/info.0.json", [comicNumber integerValue]];
	NSURL *feedURL = [NSURL URLWithString:([comicNumber isEqualToNumber:@0] ? @"http://xkcd.com/info.0.json" : feedURLString)];
    return [NSURLRequest requestWithURL:feedURL];
}

@end
