//
//  NTSComicViewController.m
//  NightShade
//
//  Created by Josh Kugelmann on 16/05/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import "NTSComicViewController.h"
#import "NTSComic.h"

@interface NTSComicViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *comicImageView;

// I find it handy to declare methods such as these too, so if this class is refactored and that method is left out, a warning is generated.
- (void)_handleDoubleTap:(UITapGestureRecognizer *)recognizer;
- (CGRect)_zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center;

@end


@implementation NTSComicViewController

#pragma mark - View Lifecycle
- (instancetype)initWithComic:(NTSComic *)comic
{
	self = [self initWithNibName:nil bundle:nil];
	
	if (self) {
		_comic = comic;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = self.comic.title;
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
	
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	self.navigationItem.rightBarButtonItem = infoItem;
    
	self.scrollView = [[UIScrollView alloc] init];
	self.scrollView.delegate = self;
	
    self.comicImageView = [[UIImageView alloc] init];
    self.comicImageView.userInteractionEnabled = YES;

    // Should this be here?
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.comicImageView addGestureRecognizer:doubleTapRecognizer];

	
	[self.scrollView addSubview:self.comicImageView];
	[self.view addSubview:self.scrollView];
    
	self.comicImageView.image = self.comic.image;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

#pragma mark - Layout
- (void)layoutViews
{
	CGSize viewSize = self.view.bounds.size;
	CGSize comicSize = self.comic.image.size;
	
	self.comicImageView.frame = CGRectMake(0, 0, comicSize.width, comicSize.height);
    
	self.scrollView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
	self.scrollView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
	self.scrollView.contentSize = comicSize;
	self.scrollView.minimumZoomScale = (self.scrollView.frame.size.width - self.scrollView.contentInset.left * 2) / self.scrollView.contentSize.width;
	self.scrollView.maximumZoomScale = 1.8f;
	self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

#pragma mark - UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.comicImageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Tap Handling
- (void)_handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    CGFloat newScale = ((self.scrollView.zoomScale > self.scrollView.minimumZoomScale) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale);
    // Mimic the behaviour of the native Photos app: Zoom out if scale > minimum, else zoom in.
    
    [self.scrollView zoomToRect:[self _zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]]
                       animated:YES];
}

// http://developer.apple.com/library/ios/#samplecode/ScrollViewSuite/Listings/1_TapToZoom_Classes_RootViewController_m.html#//apple_ref/doc/uid/DTS40008904-1_TapToZoom_Classes_RootViewController_m-DontLinkElementID_6
- (CGRect)_zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{    
    CGRect zoomRect = CGRectZero;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    
    // Set the correct origin that `center` is at the center of zoom rect.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0f);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0f);
    
    return zoomRect;
}

@end
