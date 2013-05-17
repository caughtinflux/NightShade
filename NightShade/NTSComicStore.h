/*
 NTSComicStore.h
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

#import <Foundation/Foundation.h>

@class NTSComic;

/*
 NTSComicStore only saves to disk when -[NTSComicStore commitChanges] is called. Until then, all changes due to addComicToStore: and removeComicFromStore: will only be kept in memory.
 This is useful in cases where the user may not want to save all the visible comics to disk.
 
 NTSComicStore is thread safe. (At least, as far as I have seen... ;P)
*/

@interface NTSComicStore : NSObject

+ (instancetype)defaultStore;

// Adds/Removes comics from the store. Use -addComicToStore: even to override a comic that already exists
- (void)addComicToStore:(NTSComic *)comic;
- (void)removeComicFromStore:(NTSComic *)comic;


- (NTSComic *)comicWithNumber:(NSNumber *)number;

// Returns an array of NSNumber objects representing all comics currently in the store.
// They can be retrieved using comicWithNumber:
- (NSArray *)allAvailableComics;

- (NTSComic *)latestComic;

- (void)refreshComics;
- (void)commitChangesWithCompletionHandler:(void(^)(void))completionHandler;

@end
