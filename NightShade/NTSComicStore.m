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

#define kComicsDirectory [((NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0]) stringByAppendingString:@"/Comics/"]

@interface NTSComicStore () <NSFileManagerDelegate>
{
@private
    // Use our own instance of NSFileManager, for it will be used in background threads
    NSFileManager *_fileManager;
    
    // Use this mutable dictionary to store all the comics in memory. The comic number is the key to its respective comic.
    NSMutableDictionary *_comicsDict;
    
    NSArray *_comicNumbers;
    BOOL _comicNumbersNeedRefresh;
}

- (void)_createComicsDirectoryIfNecessary;
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
        [self _createComicsDirectoryIfNecessary];
    }
    return self;
}

- (void)addComicToStore:(NTSComic *)comic
{
    @synchronized(self) {
        _comicsDict[comic.comicNumber] = comic;
        // Set _comicNumbersNeedRefresh to YES so that the next time -allAvailableComics is accessed, the array containing all the comic numbers are updated.
        _comicNumbersNeedRefresh = YES;
    }
}

- (void)removeComicFromStore:(NTSComic *)comic
{
    @synchronized(self) {
        [_comicsDict removeObjectForKey:comic.comicNumber];
        _comicNumbersNeedRefresh = YES;
    }
}

- (NTSComic *)comicWithNumber:(NSNumber *)number
{
    return _comicsDict[number];
}

- (NSArray *)allAvailableComics
{
    // Only sort _comicNumbers if a refresh is required
    if (!_comicNumbers || _comicNumbersNeedRefresh) {
        _comicNumbers = [[_comicsDict allKeys] sortedArrayUsingComparator:^(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        }];
        
        _comicNumbers = [[_comicNumbers reverseObjectEnumerator] allObjects];
        
        _comicNumbersNeedRefresh = NO;
    }
    
    return _comicNumbers;
}

- (void)refreshComics
{
    @synchronized(self) {
        
        NSArray *dirContents = [_fileManager contentsOfDirectoryAtPath:kComicsDirectory error:NULL];
        
        _comicsDict = nil; // Make sure the current dictionary is released.
        _comicsDict = [[NSMutableDictionary alloc] initWithCapacity:dirContents.count];
        
        for (NSString *comicName in dirContents) {
            // Iterate through the paths, creating and adding comic objects as required.
            if ([comicName hasSuffix:@".ntscomic"]) {
                NTSComic *comic = [NTSComic comicWithContentsOfFile:[kComicsDirectory stringByAppendingString:comicName]];
                if (comic) {
                    _comicsDict[comic.comicNumber] = comic;
                }
                else {
                    NSLog(@"An error occurred when creating a comic from %@", comicName);
                }
            }
        }
    }

}

- (void)commitChangesWithCompletionHandler:(void(^)(void))completionHandler
{
    @synchronized(self) {
        [_comicsDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSNumber *key, NTSComic *comic, BOOL *stop) {
            [comic saveToFileAtPath:[self _pathForComicWithNumber:key]];
        }];
        
        if (completionHandler) {
            completionHandler();
        }
    }
}


#pragma mark - Private Methods
- (void)_createComicsDirectoryIfNecessary
{
    @synchronized(self) {
        [_fileManager createDirectoryAtPath:kComicsDirectory
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:NULL]; // Doing this with withIntermediateDirectories set makes sure that it doesn't cause an error if the file already exists.
    }
}

- (NSString *)_pathForComicWithNumber:(NSNumber *)number
{
    return [kComicsDirectory stringByAppendingFormat:@"%@.ntscomic", [number stringValue]];
}

@end
