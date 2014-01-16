//
//  PointEditorView.m
//  VoronoiFortune
//
//  Created by Mikko on 16/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PointEditorView.h"
#import "VoronoiGraphics.h"


@interface PointEditorView ()
@property (readonly) VoronoiGraphics *vorGraphics;
@end


@implementation PointEditorView {
    VoronoiGraphics *_vorGraphics;
}

@synthesize controller;

- (VoronoiGraphics *)vorGraphics
{
    if (_vorGraphics == nil) {
        _vorGraphics = [[VoronoiGraphics alloc] init];
    }
    return _vorGraphics;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [_vorGraphics release];
}

- (void)newSiteAt:(CGPoint)point
{
    self.vorGraphics.clippingBounds = self.bounds;
    CGRect rect = [self.vorGraphics getBoundsForSite:point];
    [self setNeedsDisplayInRect:rect];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // NSLog(@"%s", __func__);
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    for (NSValue *val in self.controller.pointSet) {
        CGPoint p = [val CGPointValue];
        // NSLog(@"%s (%f, %f)", __func__, p.x, p.y);
        CGRect siteRect = [self.vorGraphics getBoundsForSite:p];
        if (CGRectIntersectsRect(rect, siteRect)) {
            [self.vorGraphics drawSiteAt:p 
                                   state:VOR_SITE_DEFAULT 
                               inContext:context];
        }
    }
    CGContextStrokePath(context);
}

@end



