//
//  NTSTilesViewController.m
//  NightShade
//
//  Created by Aditya KD on 06/04/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import "NTSTilesViewController.h"
#import "NTSComicPreviewCell.h"
#import "NTSComicViewController.h"

#import "NTSAPIRequest.h"
#import "NTSComic.h"
#import "NTSComicStore.h"

@interface NTSTilesViewController ()

- (NTSComic *)_comicForIndexPath:(NSIndexPath *)ip;
- (NSIndexPath *)_indexPathForComic:(NTSComic *)comic;
- (void)_addLatestComicToCollectionAndStore;
- (void)_downloadMissingItemsInRange:(NSRange)range;

@end


@implementation NTSTilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.collectionView.delegate = self;
    
    [[NTSComicStore defaultStore] refreshComics];
    [self _addLatestComicToCollectionAndStore];
    [self _downloadMissingItemsInRange:NSMakeRange(300, 20)];
	[[self collectionView] registerClass:[NTSComicPreviewCell class] forCellWithReuseIdentifier:@"NTSComicPreviewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:animated];
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
    return [[NTSComicStore defaultStore] allAvailableComics].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *comicCellIdentifer = @"NTSComicPreviewCell";
    
    NTSComicPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:comicCellIdentifer forIndexPath:indexPath];
    cell.imageView.image = [self _comicForIndexPath:indexPath].image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	NTSComic *comic = [self _comicForIndexPath:indexPath];
	NTSComicViewController *comicViewController = [[NTSComicViewController alloc] initWithComic:comic];

	//UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	
	[[self navigationController] pushViewController:comicViewController animated:YES];
}

#pragma mark - Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? CGSizeMake(100, 100) : CGSizeMake(150, 150);
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
    return [[NTSComicStore defaultStore] comicWithNumber:[[NTSComicStore defaultStore] allAvailableComics][ip.item]];
}

- (NSIndexPath *)_indexPathForComic:(NTSComic *)comic
{
    return [NSIndexPath indexPathForItem:[[[NTSComicStore defaultStore] allAvailableComics] indexOfObject:comic.comicNumber] inSection:0];
}

- (void)_addLatestComicToCollectionAndStore
{
    [NTSAPIRequest downloadLatestComicWithImage:YES completion:^(NTSComic *comic, NSError *error) {
        if (error || ([self _localComicHasImage:comic.comicNumber])) {
            return;
        }
        
        [[NTSComicStore defaultStore] addComicToStore:comic];
        [[NTSComicStore defaultStore] commitChangesWithCompletionHandler:nil];
        
        
        RUN_ON_MAIN_QUEUE(^{ [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]]; });
    }];
}

- (void)_downloadMissingItemsInRange:(NSRange)range
{
    [UIApp setNetworkActivityIndicatorVisible:YES];
    
    NSInteger targetNumber = range.location + range.length;
    
    for (NSInteger comicNumber = range.location; comicNumber <= targetNumber; comicNumber++) {
        if ([self _localComicHasImage:@(comicNumber)]) {
            if (comicNumber == targetNumber) {
                [UIApp setNetworkActivityIndicatorVisible:NO];
            }
            continue;
        }
        [NTSAPIRequest downloadComicWithNumber:@(comicNumber) getImage:YES withCompletion:^(NTSComic *comic, NSError *error) {
            if (error) {
                [UIApp setNetworkActivityIndicatorVisible:NO];
                return;
            }
            
            [[NTSComicStore defaultStore] addComicToStore:comic];
            RUN_ON_MAIN_QUEUE(^{ [self.collectionView insertItemsAtIndexPaths:@[[self _indexPathForComic:comic]]]; });
        }];
    }
}

- (BOOL)_localComicHasImage:(NSNumber *)number
{
    // !!!!!!!
    return !!([[NTSComicStore defaultStore] comicWithNumber:number].image);
}

@end
