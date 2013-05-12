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
	[self downloadComicWithNumber:@0 getImage:getImage withCompletion:handler];
}

+ (void)downloadComicWithNumber:(NSNumber *)comicNumber getImage:(BOOL)getImage withCompletion:(NTSCompletionHandler)handler;
{
    NSAssert((handler != nil), @"A completion handler must be called into NTSAPIRequest calls!");
    
	[NSURLConnection sendAsynchronousRequest:[self _URLRequestForComicNumber:comicNumber] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {		
		if (error) {
            NSLog(@"Error downloading comic data. %i : %@", error.code, error.localizedDescription);
            handler(nil, error);
            return;
        }
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NTSComic *comic = [[NTSComic alloc] initWithJSONDictionary:dictionary];
        
        if (getImage) {
            [comic downloadImageWithCompletionHandler:^(UIImage *image, NSError *imgError) {
                handler(comic, error);
            }];
        }
	}];
}

+ (NSURLRequest *)_URLRequestForComicNumber:(NSNumber *)comicNumber
{
    NSString *feedURLString = [NSString stringWithFormat:@"http://xkcd.com/%i/info.0.json", [comicNumber integerValue]];
	NSURL *feedURL = [NSURL URLWithString:([comicNumber isEqualToNumber:@0] ? @"http://xkcd.com/info.0.json" : feedURLString)];
    return [[NSURLRequest alloc] initWithURL:feedURL];
}

@end
