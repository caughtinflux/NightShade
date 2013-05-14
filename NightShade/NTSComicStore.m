/*
 NTSComicStore.m
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

#import "NTSComicStore.h"
#import "NTSComic.h"

@interface NTSComicStore () <NSFileManagerDelegate>
{
    // Use our own instance of NSFileManager, for it will be used in background threads
    NSFileManager *_fileManager;
}

- (void)_createComicsDirectory;
- (NSString *)_pathForComicWithNumber:(NSNumber *)number;

@end

@implementation NTSComicStore

#pragma mark - Public Methods
+ (instancetype)defaultStore
{
    static NTSComicStore *defaultStore;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[self alloc] init];
    });
    
    return defaultStore;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _fileManager = [[NSFileManager alloc] init];
        _fileManager.delegate = self;
        [self _createComicsDirectory];
    }
    return self;
}

- (void)addComicToStore:(NTSComic *)comic force:(BOOL)forced
{
    @synchronized(self) {
        NSString *path = [self _pathForComicWithNumber:[comic comicNumber]];
        if (forced == NO) {
            if (![_fileManager fileExistsAtPath:path]) {
                [comic saveToFileAtPath:path];
            }
        }
        else {
            // Remove the existing comic if a comic exists already
            [self removeComicFromStore:comic usingHandler:^(NSError *error){
                [comic saveToFileAtPath:path]; 
            }];
        }
    }
}

- (void)removeComicFromStore:(NTSComic *)comic usingHandler:(void (^) (NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self) {
            NSError *error = nil;
            [_fileManager removeItemAtPath:[self _pathForComicWithNumber:[comic comicNumber]] error:&error];
            if (handler) {
                handler(error);
            }
        }
    });
}

- (NTSComic *)comicWithNumber:(NSNumber *)number
{
    return [[NTSComic alloc] initWithContentsOfFile:[self _pathForComicWithNumber:number]];
}

- (NSArray *)allLocalComics
{
    NSString *comicsDirectoryPath = [((NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0]) stringByAppendingString:@"/Comics/"];
    NSArray *dirContents = [_fileManager contentsOfDirectoryAtPath:comicsDirectoryPath error:NULL];
    
    // Order it by number
    dirContents = [dirContents sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 localizedStandardCompare:obj2];
    }];
    
    NSMutableArray *localComics = [NSMutableArray arrayWithCapacity:dirContents.count];
    
    for (NSString *comicName in dirContents) {
        // Iterate through the paths, creating and adding comic objects as required.
        if ([comicName hasSuffix:@".ntscomic"]) {
            NSString *fullPath = [comicsDirectoryPath stringByAppendingString:comicName];
            [localComics addObject:[[NTSComic alloc] initWithContentsOfFile:fullPath]];
        }
    }
    
    // Do not want bad things happening, if by accident, so create NSArray.
    return [NSArray arrayWithArray:localComics];
}

#pragma mark - Private Methods
- (void)_createComicsDirectory
{
    @synchronized(self) {
        [_fileManager createDirectoryAtPath:[((NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0]) stringByAppendingString:@"/Comics/"]
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:NULL]; // Doing this with withIntermediateDirectories set makes sure that it doesn't cause an error if the file already exists.
    }
}

- (NSString *)_pathForComicWithNumber:(NSNumber *)number
{
    NSString *comicsDirectoryPath = [((NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0]) stringByAppendingString:@"/Comics/"];
    return [comicsDirectoryPath stringByAppendingFormat:@"%@.ntscomic", [number stringValue]];
}

@end
