//
//  VoronoiGraphics.h
//  VoronoiFortune
//
//  Created by Mikko on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiBeachline.h"
#import <stdbool.h>


@class VoronoiBeachLine;


VDouble line_intersect_horiz(CGPoint A, CGPoint B, CGFloat fooY);

VDouble line_intersect_vert(CGPoint A, CGPoint B, CGFloat vertX);

bool rayRectIntersect(CGPoint rayOrigin, CGPoint rayDirection,
                      CGRect bounds, CGPoint *intersect);

typedef enum {
    VOR_SITE_DEFAULT,
    VOR_SITE_CURRENT,
    VOR_SITE_IN_BEACHLINE
} VoronoiSiteState;

@interface VoronoiGraphics : NSObject

@property (assign, nonatomic)bool strokeOrFill;

@property (assign, nonatomic)CGColorRef siteBorderColor;
@property (assign, nonatomic)CGColorRef siteInBeachlineBorderColor;

@property (assign, nonatomic)CGColorRef siteDefaultColor;
@property (assign, nonatomic)CGColorRef siteCurrentColor;
@property (assign, nonatomic)CGColorRef siteInBeachlineColor;

@property (assign, nonatomic)CGColorRef beachlineColor;
@property (assign, nonatomic)CGColorRef diagramEdgeColor;
@property (assign, nonatomic)CGColorRef scanlineColor;

@property (assign, nonatomic)CGFloat siteRadius;
@property (assign, nonatomic)CGFloat siteThickness;

@property (assign, nonatomic)CGFloat beachlineThickness;
@property (assign, nonatomic)CGFloat scanlineThickness;
@property (assign, nonatomic)CGFloat diagramEdgeThickness;

@property (assign, nonatomic)CGRect clippingBounds;


- (CGRect)getBoundsForSite:(CGPoint)location;

- (void)drawSiteAt:(CGPoint)location
             state:(VoronoiSiteState)state
         inContext:(CGContextRef)context;

- (CGRect)getBoundsForBeachline:(VoronoiBeachLine *)beachline
                     atScanline:(CGFloat)scanline
                     viewBounds:(CGRect)viewBounds;

- (void)drawBoundsBoxInContext:(CGContextRef)context;

- (void)drawBeachline:(VoronoiBeachLine *)beachline 
           atScanline:(CGFloat)scanline
            inContext:(CGContextRef)context;

- (void)drawVoronoiDiagram:(VoronoiDiagram *)diagram
                 inContext:(CGContextRef)context;

- (void)drawScanlineAt:(CGFloat)scanline
             inContext:(CGContextRef)context;

@end
