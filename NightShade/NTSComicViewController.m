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
@end

@implementation NTSComicViewController

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
	
	self.scrollView = [[UIScrollView alloc] init];
	self.scrollView.delegate = self;
	
	self.comicImageView = [[UIImageView alloc] init];
	
	[self.scrollView addSubview:self.comicImageView];
	[self.view addSubview:self.scrollView];

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = self.comic.title;
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	
	self.navigationItem.rightBarButtonItem = infoItem;
	self.comicImageView.image = self.comic.image;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self layoutViews];
}

#pragma mark - Layout
- (void)layoutViews
{
	CGSize viewSize = self.view.bounds.size;
	CGSize comicSize = self.comic.image.size;
	CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
	
	self.comicImageView.frame = CGRectMake(0, 0, comicSize.width, comicSize.height);

	self.scrollView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height - navBarHeight);
	self.scrollView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
	self.scrollView.contentSize = comicSize;
	self.scrollView.minimumZoomScale = (self.scrollView.frame.size.width - self.scrollView.contentInset.left * 2) / self.scrollView.contentSize.width;
	self.scrollView.maximumZoomScale = 2.0f;
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

@end
