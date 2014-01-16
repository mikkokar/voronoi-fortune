//
//  VoronoiView.m
//  VoronoiFortune
//
//  Created by Mikko on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiView.h"
#include <math.h>
#include "VoronoiMath.h"
#include "VoronoiBeachline.h"
#include "VoronoiGraphics.h"
#include "VoronoiDefs.h"

@interface VoronoiView ()
@property (readonly) VoronoiGraphics *vorGraphics;
@end


@implementation VoronoiView {
    VoronoiGraphics *_vorGraphics;
    CGFloat prevScanline;
    CGRect prevVisibleBounds;
}

@synthesize controller;
@synthesize algorithm;
@synthesize showCircles;


- (VoronoiGraphics *)vorGraphics
{
    if (_vorGraphics == nil) {
        _vorGraphics = [[VoronoiGraphics alloc] init];
        _vorGraphics.clippingBounds = self.bounds;
    }
    return _vorGraphics;
}


- (id)getLastEvent
{
    return [self.controller.algorithm.pastEvents lastObject];
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
    [_vorGraphics release];
    [super dealloc];
}



- (void)drawCircleAtPoint:(CGPoint)p 
               withRadius:(CGFloat)radius
                   dashed:(Boolean)dashed
                inContext:(CGContextRef)context
{
    CGFloat dash_lengths[] = {5.0, 5.0};
    CGContextSaveGState(context);
    
    if (dashed) {
        CGContextSetLineDash(context, 5, dash_lengths, 2);
    }
    
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


- (void)drawBeachLineInContext:(CGContextRef)context
{
    // Draw beachline:
    [self.vorGraphics drawBeachline:self.controller.algorithm.beachline 
                         atScanline:self.controller.scanline
                          inContext:context];
    
    
    // Highlight all points contributing to scanline:
    BeachlineIterator_t iterator;
    VoronoiBeachLine *beachline = self.controller.algorithm.beachline;
    
    [beachline enumerateAtScanline:self.controller.scanline
                          iterator:&iterator];
    
    while ([beachline enumerateNext:&iterator] > 0) {
        [self.vorGraphics drawSiteAt:CGPointFromVPoint(iterator.arc.site.location)
                               state:VOR_SITE_IN_BEACHLINE
                           inContext:context];
    }    
}


- (void)drawCircleEvent:(VoronoiCircle *)circle InContext:(CGContextRef)context
{
    [self drawCircleAtPoint:CGPointFromVPoint(circle.center)
                 withRadius:circle.radius 
                     dashed:false 
                  inContext:context];
}


- (void)drawSiteEvent:(VoronoiSite *)site InContext:(CGContextRef)context
{
    [self.vorGraphics drawSiteAt:CGPointFromVPoint(site.location)
                           state:VOR_SITE_CURRENT
                       inContext:context];
}


- (void)drawPointsInContext:(CGContextRef)context
{
    int i = 0;
    for (NSValue *val in self.controller.voronoiSites) {
        CGPoint p = [val CGPointValue];
        [self.vorGraphics drawSiteAt:p state:VOR_SITE_DEFAULT inContext:context];
        i++;
    }    
}


- (void)drawCircleEventsInContext:(CGContextRef)context
{
    id <VoronoiEvent> event;
    for (event in self.controller.algorithm.futureEvents) {
        if ([event isKindOfClass:[VoronoiCircle class]]) {
            VoronoiCircle *circle = (VoronoiCircle *)event;
            [self drawCircleAtPoint:CGPointFromVPoint(circle.center)
                         withRadius:circle.radius
                             dashed:true 
                          inContext:context];
        }
    }    
}


- (void)updateContent
{
    CGRect newBounds = [self.vorGraphics
                        getBoundsForBeachline:self.controller.algorithm.beachline
                                    atScanline:self.controller.scanline
                                    viewBounds:self.bounds];
    CGRect currentBounds = CGRectUnion(newBounds, prevVisibleBounds);
    // NSLog(@"newBounds:         %@", NSStringFromCGRect(newBounds));
    // NSLog(@"prevVisibleBounds: %@", NSStringFromCGRect(prevVisibleBounds));
    // NSLog(@"currentBounds:     %@", NSStringFromCGRect(currentBounds));
    //[self setNeedsDisplayInRect:currentBounds];
    [self setNeedsDisplay];
    prevVisibleBounds = newBounds;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.controller.algorithm == nil) {
        //[self.vorGraphics setClippingBounds:self.bounds];
        [self drawPointsInContext:context];
    } else {
        //[self.vorGraphics setClippingBounds:rect];
        [self.vorGraphics drawBoundsBoxInContext:context];
        [self drawPointsInContext:context];
        if (self.showCircles) {
            [self drawCircleEventsInContext:context];
        }
        [self drawBeachLineInContext:context];
        
        [self.vorGraphics drawVoronoiDiagram:self.controller.algorithm.diagram
                                   inContext:context];
        
        if ([self.controller.currentEvent isKindOfClass:[VoronoiSite class]]) {
            VoronoiSite *site = (VoronoiSite *)self.controller.currentEvent;
            [self drawSiteEvent:site InContext:context];
        } else if (self.showCircles &&
                   [self.controller.currentEvent 
                    isKindOfClass:[VoronoiCircle class]]) {
            VoronoiCircle *circle = (VoronoiCircle *)self.controller.currentEvent;
            if (self.controller.scanline < circle.location.y + 20) {
                [self drawCircleEvent:circle InContext:context];
            }
        }
        
        [_vorGraphics drawScanlineAt:self.controller.scanline inContext:context];
        // [self drawFutureEventsInContext:context];
    }
    prevScanline = self.controller.scanline;
}


@end
