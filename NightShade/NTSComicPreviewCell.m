/*
 NTSCollectionViewCell.m
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

#import "NTSComicPreviewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface NTSComicPreviewCell ()
@property (nonatomic, strong) UIView *dimmingView;
@end

@implementation NTSComicPreviewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self) {
		self.layer.shouldRasterize = YES;
		self.layer.rasterizationScale = [UIScreen mainScreen].scale;
		
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		_imageView.clipsToBounds = YES;
		
		_dimmingView = [[UIView alloc] init];
		_dimmingView.backgroundColor = [UIColor blackColor];
		_dimmingView.alpha = 0.0f;
		
		[self addSubview:_imageView];
		[self addSubview:_dimmingView];
    }
	
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
	self.dimmingView.frame = self.bounds;
    self.imageView.frame = self.bounds;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}


- (void)setShowsActivityIndicator:(BOOL)showsActivityIndicator
{
    
}

- (void)setHighlighted:(BOOL)highlighted
{
	// XXX: Should this be dot or bracket syntax?
	super.highlighted = highlighted;
	
	self.dimmingView.alpha = (self.highlighted ? 0.5f : 0.0f);
}



@end
