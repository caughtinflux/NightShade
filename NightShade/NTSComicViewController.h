//
//  NTSComicViewController.h
//  NightShade
//
//  Created by Josh Kugelmann on 16/05/13.
//  Copyright (c) 2013 ProtoFlux. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTSComic;

@interface NTSComicViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NTSComic *comic;

- (instancetype)initWithComic:(NTSComic *)comic;

@end
