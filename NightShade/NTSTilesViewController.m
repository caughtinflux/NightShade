//
//  NTSTilesViewController.m
//  NightShade
//
//  Created by Aditya KD on 06/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import "NTSTilesViewController.h"
#import "NTSCollectionViewCell.h"

#import "NTSAPIRequest.h"
#import "NTSComic.h"
#import "NTSComicStore.h"

@interface NTSTilesViewController ()
{
    NSArray *_allComics;
}

- (NTSComic *)_comicForIndexPath:(NSIndexPath *)ip;
- (void)_addLatestComicToCollectionAndStore;
- (void)_downloadMissingItemsInRange:(NSRange)range addToStore:(BOOL)shouldAddToStore;
- (void)_refreshComics;

@end


@implementation NTSTilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:1.f];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.collectionView.delegate = self;
    
    
    [self _refreshComics];
    [self _addLatestComicToCollectionAndStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = _allComics.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"NTSComicPreviewCell";
    
    NTSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [[self _comicForIndexPath:indexPath] image];
    
    return cell;
}

#pragma mark - Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

#pragma mark - Private
- (NTSComic *)_comicForIndexPath:(NSIndexPath *)ip
{
    return _allComics[ip.item];
}

- (void)_addLatestComicToCollectionAndStore
{
    [NTSAPIRequest downloadLatestComicWithImage:YES completion:^(NTSComic *comic, NSError *error) {
        if (error || ([self _localComicHasImage:comic.comicNumber])) {
            return;
        }
        
        [[NTSComicStore defaultStore] addComicToStore:comic force:YES];
        [self _refreshComics];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        });
        
    }];
}

- (void)_downloadMissingItemsInRange:(NSRange)range addToStore:(BOOL)shouldAddToStore
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSInteger targetNumber = range.location + range.length;
    
    for (NSInteger comicNumber = range.location; comicNumber <= targetNumber; comicNumber++) {
        if ([self _localComicHasImage:@(comicNumber)]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            continue;
        }
        [NTSAPIRequest downloadComicWithNumber:@(comicNumber) getImage:YES withCompletion:^(NTSComic *comic, NSError *error) {
            if (error) {
                return;
            }
            
            if (shouldAddToStore) {
                [[NTSComicStore defaultStore] addComicToStore:comic force:YES];
            }
            
            if (comicNumber == targetNumber) {
                [self _refreshComics];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }];
    }
}

- (BOOL)_localComicHasImage:(NSNumber *)number
{
    // !!!!!!!
    return !!([[NTSComicStore defaultStore] comicWithNumber:number].image);
}

- (void)_refreshComics
{
    _allComics = [[[[NTSComicStore defaultStore] allLocalComics] reverseObjectEnumerator] allObjects];
}

@end
