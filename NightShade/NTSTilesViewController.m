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


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kDefaultTileSize (IS_IPAD ? CGSizeMake(200, 200) : CGSizeMake(100, 100));


@interface NTSTilesViewController ()

- (BOOL)localComicHasImage:(NSNumber *)number;

- (NTSComic *)comicForIndexPath:(NSIndexPath *)ip;
- (NSIndexPath *)indexPathForComic:(NTSComic *)comic;

- (void)populateCollectionViewWithLatestComics;
- (void)downloadMissingItemsInRange:(NSRange)range;

// Downloads 20 more comics, adds them to the store *and* collection view.
- (void)downloadMoreComics;

@end

@implementation NTSTilesViewController
#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[NTSComicPreviewCell class] forCellWithReuseIdentifier:@"NTSComicPreviewCell"];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self populateCollectionViewWithLatestComics];
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
    cell.imageView.image = [self comicForIndexPath:indexPath].image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	NTSComic *comic = [self comicForIndexPath:indexPath];
	NTSComicViewController *comicViewController = [[NTSComicViewController alloc] initWithComic:comic];

	//UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	
	[[self navigationController] pushViewController:comicViewController animated:YES];
}

#pragma mark - Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        CGSize imageSize = [self comicForIndexPath:indexPath].image.size;
        // Show the latest comic with a larger size. Thanks, @kirbylover4000
        CGFloat width = ((imageSize.width < collectionView.bounds.size.width) ? imageSize.width : collectionView.bounds.size.width);
        CGFloat height = ((imageSize.height < CGRectGetHeight(collectionView.bounds) * 0.5f) ? imageSize.height : CGRectGetHeight(collectionView.bounds) * 0.6f);
        
        return CGSizeMake(width, height);
    }
    
    return kDefaultTileSize;
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
- (BOOL)localComicHasImage:(NSNumber *)number
{
    // !!!!!!!
    return !!([[NTSComicStore defaultStore] comicWithNumber:number].image);
}

- (NTSComic *)comicForIndexPath:(NSIndexPath *)ip
{
    return [[NTSComicStore defaultStore] comicWithNumber:[[NTSComicStore defaultStore] allAvailableComics][ip.item]];
}

- (NSIndexPath *)indexPathForComic:(NTSComic *)comic
{
    return [NSIndexPath indexPathForItem:[[[NTSComicStore defaultStore] allAvailableComics] indexOfObject:comic.comicNumber] inSection:0];
}

- (void)populateCollectionViewWithLatestComics
{
    [NTSAPIRequest downloadLatestComicWithImage:YES completion:^(NTSComic *comic, NSError *error) {
        if (error) {
            NSLog(@"Error occurred when downloading the latest comic: Error %i:%@", error.code, error.localizedDescription);
            return;
        }
        
        // Adding the comic again if it exists doesn't create a duplicate, it only replaces. If comic is nil and a local version exists, the store keeps that version.
        [[NTSComicStore defaultStore] addComicToStore:comic];
        [[NTSComicStore defaultStore] commitChangesWithCompletionHandler:^{
            if ([self localComicHasImage:comic.comicNumber] == NO) {
                // Add the latest comic if necessary.
                RUN_ON_MAIN_QUEUE(^{ [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]]; });
            }
            
            // Now that at least one comic is being shown, download 20 older comics
            [self downloadMissingItemsInRange:NSMakeRange([comic.comicNumber unsignedIntegerValue] - 21, 20)];
        }];
    }];
}

- (void)downloadMissingItemsInRange:(NSRange)range
{
    NSInteger targetNumber = range.location + range.length;
    NSMutableArray *comicsToDownload = [NSMutableArray array];
    
    // Iterate through the range requested, creating a new array of the comics to download if the comic doesn't have an image already
    for (NSInteger comicNumber = range.location; comicNumber <= targetNumber; comicNumber++) {
        if (![self localComicHasImage:@(comicNumber)]) {
            [comicsToDownload addObject:@(comicNumber)];
        }
    }
    
    UIApp.networkActivityIndicatorVisible = YES;
    [comicsToDownload enumerateObjectsUsingBlock:^(NSNumber *comicNumber, NSUInteger index, BOOL *stop) {
        [NTSAPIRequest downloadComicWithNumber:comicNumber getImage:YES completion:^(NTSComic *comic, NSError *error) {
            RUN_ON_MAIN_QUEUE(^{
                if (index == (comicsToDownload.count - 1)) {
                    // Turn of the activity indicator if it's the last object in the enumeration
                    UIApp.networkActivityIndicatorVisible = NO;
                }
                
                if (!error) {
                    [[NTSComicStore defaultStore] addComicToStore:comic];
                    [self.collectionView insertItemsAtIndexPaths:@[[self indexPathForComic:comic]]];
                }
            });
            
        }];
    }];
}

- (void)downloadMoreComics
{
    NSNumber *lastComicNumber = [[NTSComicStore defaultStore] allAvailableComics].lastObject;
    [self downloadMissingItemsInRange:NSMakeRange([lastComicNumber unsignedIntegerValue] - 21, 20)];
}

@end
