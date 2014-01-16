//
//  VoronoiGraphics.m
//  VoronoiFortune
//
//  Created by Mikko on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiGraphics.h"
#import "VoronoiMath.h"
#include "math.h"
#include "assert.h"
#include "VoronoiDefs.h"

/*
 * Computes an intersection of ray and a bounding rectangle. The ray must
 * originate inside the bounding box. The ray is shot at given direction.
 * The function returns a point where ray crosses the bounding rectangle.
 *
 * The behavior is unspecified if the rayOrigin is not within bounding
 * rectangle.
 */
static
bool rayHorizLineIntersect(CGPoint rayOrigin, CGPoint rayDirection,
                           CGFloat yCoord, CGFloat *xPoint)
{
    CGFloat n;    
    if (rayDirection.y == 0.0 || !xPoint) {
        return false;
    }
    
    bool retval = false;
    n = ((yCoord - rayOrigin.y)/rayDirection.y);
    if (n >= 0) {
        *xPoint = rayOrigin.x + n*rayDirection.x;
        retval = true;
    }
    return retval;
}

static
bool rayVertLineIntersect(CGPoint rayOrigin, CGPoint rayDirection,
                          CGFloat xCoord, CGFloat *yPoint)
{
    CGFloat n;    
    if (rayDirection.x == 0.0 || !yPoint) {
        return false;
    } 
    
    bool retval = false;
    n = ((xCoord - rayOrigin.x)/rayDirection.x);
    if (n >= 0.0) {
        *yPoint = rayOrigin.y + n*rayDirection.y;
        retval = true;    
    }
    return retval;
}


bool rayRectIntersect(CGPoint rayOrigin, CGPoint rayDirection,
                      CGRect bounds, CGPoint *intersect)
{
    bool found;
    CGFloat intersectCoord;
    CGPoint intersectPoint;
    assert(CGRectContainsPoint(bounds, rayOrigin));
    
    CGFloat boundsTop = CGRectGetMinY(bounds);
    CGFloat boundsBottom = CGRectGetMaxY(bounds);
    CGFloat boundsLeft = CGRectGetMinX(bounds);
    CGFloat boundsRight = CGRectGetMaxX(bounds);
    
    // Horizontal top
    found = rayHorizLineIntersect(rayOrigin, rayDirection,
                                  boundsTop, &intersectCoord);
    intersectPoint = CGPointMake(intersectCoord, boundsTop);
    if (found && CGRectContainsPoint(bounds, intersectPoint)) {
        *intersect = intersectPoint;
        return true;
    }
    
    // Horizontal bottom
    found = rayHorizLineIntersect(rayOrigin, rayDirection,
                                  boundsBottom - 1, &intersectCoord);
    intersectPoint = CGPointMake(intersectCoord, boundsBottom - 1);
    if (found && CGRectContainsPoint(bounds, intersectPoint)) {
        *intersect = intersectPoint;
        return true;
    }
    
    // Vertical left
    found = rayVertLineIntersect(rayOrigin, rayDirection,
                                 boundsLeft, &intersectCoord);
    intersectPoint = CGPointMake(boundsLeft, intersectCoord);
    if (found && CGRectContainsPoint(bounds, intersectPoint)) {
        *intersect = intersectPoint;
        return true;
    }
    
    // Vertical right
    found = rayVertLineIntersect(rayOrigin, rayDirection,
                                 boundsRight - 1, &intersectCoord);
    intersectPoint = CGPointMake(boundsRight - 1, intersectCoord);
    if (found && CGRectContainsPoint(bounds, intersectPoint)) {
        *intersect = intersectPoint;
        return true;
    }
    
    return false;    
}



@implementation VoronoiGraphics {
    UIColor *bbColor;
}

@synthesize siteRadius;
@synthesize siteThickness;

@synthesize siteBorderColor;
@synthesize siteInBeachlineBorderColor;

@synthesize siteCurrentColor;
@synthesize siteDefaultColor;
@synthesize siteInBeachlineColor;

@synthesize beachlineColor;
@synthesize diagramEdgeColor;
@synthesize scanlineColor;

@synthesize strokeOrFill;

@synthesize beachlineThickness;
@synthesize scanlineThickness;
@synthesize diagramEdgeThickness;

@synthesize clippingBounds;


- (VoronoiGraphics *)init
{
    self = [super init];
    if (self) {
        self.siteRadius = 4.0;
        self.siteThickness = 1.0;
        
        self.siteBorderColor = [UIColor grayColor].CGColor;

        self.siteInBeachlineBorderColor = [UIColor blueColor].CGColor;
        self.siteInBeachlineColor = [UIColor cyanColor].CGColor;
        
        self.siteDefaultColor = [UIColor lightGrayColor].CGColor;
        self.siteCurrentColor = [UIColor grayColor].CGColor;
    
        self.diagramEdgeColor = [UIColor blackColor].CGColor;
        self.scanlineColor = [UIColor blackColor].CGColor;
        self.beachlineColor = [UIColor grayColor].CGColor;
        
        self.beachlineThickness = 3.0;
        self.scanlineThickness = 1.0;
        self.diagramEdgeThickness = 1.0;
        
        bbColor = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:1.0 alpha:0.2];
    }
    return self;
}


- (void)dealloc
{
    [bbColor release];
    [super dealloc];
}


- (CGRect)getBoundsForSite:(CGPoint)location
{
    CGRect rect;
    rect.size.width = 2.0*(self.siteRadius + self.siteThickness);
    rect.size.height = 2.0*(self.siteRadius + self.siteThickness);
    rect.origin.x = location.x - (self.siteRadius + self.siteThickness);
    rect.origin.y = location.y - (self.siteRadius + self.siteThickness);
    return rect;
}


- (void)drawSiteAt:(CGPoint)location
             state:(VoronoiSiteState)state
         inContext:(CGContextRef)context
{
    CGRect siteRect = [self getBoundsForSite:location];
    
    if (CGRectIntersectsRect(self.clippingBounds, siteRect) == false) {
        return;
    }
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.siteBorderColor);
    CGContextBeginPath(context);
    if (state == VOR_SITE_DEFAULT) {
        CGContextSetFillColorWithColor(context, self.siteDefaultColor);
        // CGContextSetStrokeColorWithColor(context, self.siteDefaultColor);
    } else if (state == VOR_SITE_IN_BEACHLINE) {
        CGContextSetFillColorWithColor(context, self.siteInBeachlineColor);
        CGContextSetStrokeColorWithColor(context, self.siteInBeachlineBorderColor);
    } else if (state == VOR_SITE_CURRENT) {
        CGContextSetFillColorWithColor(context, self.siteCurrentColor);
    }
    CGContextAddArc(context, location.x, location.y, self.siteRadius, 
                    0, 2*M_PI, TRUE);
    CGContextDrawPath(context, kCGPathFillStroke);
    // CGContextFillPath(context);
    CGContextRestoreGState(context);    
}
                                 

/*
 * (CGPoint *)results must be a pointer to an CGPoint array of length 4.
 */
- (int)lineFrom:(CGPoint)p1 to:(CGPoint)p2 
            intersectsWithRect:(CGRect)rect
                    intersects:(CGPoint *)results
{
    CGPoint r1, r2;
    CGPoint ip;
    int matches = 0;
    CGRect bounds = self.clippingBounds;
    
    // Top 
    r1 = CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    r2 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    ip = lineIntersect(p1, p2, r1, r2);
    if (CGPointEqualToPoint(ip, CGPointZero) == false) {
        results[matches] = ip;
        matches++;
    }
    
    // Right
    r1 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    r2 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    ip = lineIntersect(p1, p2, r1, r2);
    if (CGPointEqualToPoint(ip, CGPointZero) == false) {
        results[matches] = ip;
        matches++;
    }
    
    // Bottom
    r1 = CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
    r2 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    ip = lineIntersect(p1, p2, r1, r2);
    if (CGPointEqualToPoint(ip, CGPointZero) == false) {
        results[matches] = ip;
        matches++;
    }
    
    // Left
    r1 = CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    r2 = CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
    ip = lineIntersect(p1, p2, r1, r2);
    if (CGPointEqualToPoint(ip, CGPointZero) == false) {
        results[matches] = ip;
        matches++;
    }    
    return matches;
}


- (CGRect)getBoundsForBeachline:(VoronoiBeachLine *)beachline
                     atScanline:(CGFloat)scanline
                     viewBounds:(CGRect)viewBounds
{
    //VoronoiBeachLine *beachline = self.controller.algorithm.beachline;
    BeachlineIterator_t iterator;
    CGRect bounds;
    
    CGFloat minY = scanline - (self.scanlineThickness + 2.0);
    CGFloat x = 0.0;
    
    [beachline enumerateAtScanline:scanline
                          iterator:&iterator];
    
    while ([beachline enumerateNext:&iterator] > 0) {
        if (iterator.domainLeft < viewBounds.origin.x &&
            iterator.domainRight < viewBounds.origin.x) {
            continue;
        } else if (iterator.domainLeft < viewBounds.origin.x &&
                   iterator.domainRight > viewBounds.origin.x)
        {
            x = 0.0;
        } else if (iterator.domainLeft > viewBounds.origin.x &&
                   (iterator.domainLeft < viewBounds.origin.x + 
                   viewBounds.size.width))
        {
            x = iterator.domainLeft;
        }
        
        CGFloat parabolaY = parabolaAtX(x, iterator.arc.site.location, scanline);
        if ((parabolaY - self.beachlineThickness) < minY) {
            minY = parabolaY;
        }
        
        if (iterator.domainRight > (viewBounds.origin.x + viewBounds.size.width))
        {
            x = viewBounds.origin.x + viewBounds.size.width;
            CGFloat parabolaY = parabolaAtX(x, iterator.arc.site.location,
                                            scanline);
            if ((parabolaY - self.beachlineThickness) < minY) {
                minY = parabolaY;
            }
            break;
        }
    }
    CGFloat bx = viewBounds.origin.x;
    CGFloat by = (minY < 0.0) ? 0.0 : minY;
    CGFloat bwidth = viewBounds.size.width;
    CGFloat bheight = scanline - by;
    bheight += self.scanlineThickness;    
    bounds = CGRectMake(bx, by, bwidth, bheight);

    assert(CGRectContainsPoint(bounds, CGPointMake(0.0, scanline)));
    
    return bounds;
}

- (void)drawBoundsBoxInContext:(CGContextRef)context
{
//    CGContextSaveGState(context);
//    CGContextSetStrokeColorWithColor(context, self.siteDefaultColor);
//    CGContextSetFillColorWithColor(context, bbColor.CGColor);
//    CGContextFillRect(context, self.clippingBounds);
//    CGContextStrokeRect(context, self.clippingBounds);
//    NSLog(@"clippingBounds: %@", NSStringFromCGRect(self.clippingBounds));
//    CGContextRestoreGState(context);
}

- (void)drawBeachline:(VoronoiBeachLine *)beachline 
           atScanline:(CGFloat)scanline
            inContext:(CGContextRef)context
{
    BeachlineIterator_t iterator;
    
    /*
     * Draw parabolic arcs:
     */
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.beachlineColor);
    //CGContextSetFillColorWithColor(context, self.beachlineColor);
    CGContextSetLineWidth(context, self.beachlineThickness);
        
    [beachline enumerateAtScanline:scanline iterator:&iterator];
    CGFloat screenX = 0.0;
    while ([beachline enumerateNext:&iterator] > 0) {
        if (screenX == 0.0 && 
            screenX > iterator.domainLeft && 
            screenX < iterator.domainRight) {
            CGFloat y = parabolaAtX(screenX, iterator.arc.site.location, 
                                    scanline);
            CGContextMoveToPoint(context, screenX, y);
            screenX++;
        }
        //if (iterator.domainRight - iterator.domainLeft < 1.0) {
        //    CGContextAddLineToPoint(context, screenX, scanline);
        //}
        while (screenX < iterator.domainRight &&
               screenX < self.clippingBounds.size.width) {
            CGFloat y = parabolaAtX(screenX, iterator.arc.site.location, 
                                    scanline);
            if (y >= 0) {
                CGContextAddLineToPoint(context, screenX, y);
            } else {
                CGContextMoveToPoint(context, screenX, 0);
            }
            screenX++;
        }
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


- (void)drawScanlineAt:(CGFloat)scanline
             inContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, self.scanlineThickness);
    CGContextSetStrokeColorWithColor(context, self.scanlineColor);
    CGContextMoveToPoint(context, 0, scanline);
    CGContextAddLineToPoint(context, self.clippingBounds.size.width, scanline);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);    
}


- (void)drawDiagramEdge:(VoronoiEdge *)edge
             atLocation:(CGPoint)location
              atContext:(CGContextRef)context
{
    //CGContextSaveGState(context);
    CGContextMoveToPoint(context, location.x, location.y);
    if (edge.src_vertex) {
        CGContextAddLineToPoint(context, 
                                edge.src_vertex.location.x, 
                                edge.src_vertex.location.y);
    } else if (edge.dst_vertex) {
        CGContextAddLineToPoint(context, 
                                edge.dst_vertex.location.x, 
                                edge.dst_vertex.location.y);        
    } else {
        CGContextAddLineToPoint(context, edge.point.x, edge.point.y);
    }
    CGContextStrokePath(context);
    //CGContextRestoreGState(context);
}


- (void)drawVoronoiDiagram:(VoronoiDiagram *)diagram
                 inContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, self.diagramEdgeColor);
    CGContextSetLineWidth(context, self.diagramEdgeThickness); 

    /*
     * NOTE: Problem: following doesn't handle the case where both end-points
     *       are outside of the bounds, but the edge passes the bounding
     *       box. This is illustrated in the following diagram:
     *
     *
     *       from  o
     *              \
     *               \
     *       ---------\---+
     *                 \  |
     *                  \ |
     *       bound box   \|
     *                    \
     *                    |\ 
     *                    | \
     *       -------------+  \
     *                        \
     *                     to  o
     */
    
    
    
    
    for (VoronoiEdge *edge in diagram.edges) {
        CGPoint from;
        CGPoint to;
        if (edge.src_vertex.infinity) {
            ParabolaBreakpoint *bp = (ParabolaBreakpoint *)edge.src_vertex.data;
            from = CGPointFromVPoint(bp.location);
        } else {
            from = edge.src_vertex.location;
        }
        
        if (edge.dst_vertex.infinity) {
            ParabolaBreakpoint *bp = (ParabolaBreakpoint *)edge.dst_vertex.data;
            to = CGPointFromVPoint(bp.location);
        } else {
            to = edge.dst_vertex.location;
        }
        
        CGRect fromp = CGRectMake(from.x - self.diagramEdgeThickness, 
                                  from.y - self.diagramEdgeThickness, 
                                  2*self.diagramEdgeThickness, 
                                  2*self.diagramEdgeThickness);
        CGRect top = CGRectMake(to.x - self.diagramEdgeThickness, 
                                to.y - self.diagramEdgeThickness, 
                                2*self.diagramEdgeThickness, 
                                2*self.diagramEdgeThickness);

        bool draw = false;
        bool from_in = CGRectIntersectsRect(self.clippingBounds, fromp);
        bool to_in = CGRectIntersectsRect(self.clippingBounds, top);
        
        if (from_in && to_in) {
            draw = true;
        } else {
            CGPoint points[4];
            int n = [self lineFrom:from to:to
                intersectsWithRect:self.clippingBounds
                        intersects:points];
            
            if (n == 1 && from_in) {
                to = points[0];
                draw = true;
            } else if (n == 1 && to_in) {
                from = points[0];
                draw = true;
            } else if (n == 2) {
                from = points[0];
                to = points[1];
                draw = true;
            }
        }
        
        if (draw) {
            // TODO: Horrible hack to avoid asserts in a hurry!
            if (!isnan(from.x) && !isnan(from.y) &&
                !isnan(to.x) && !isnan(to.y)) {
                CGContextMoveToPoint(context, from.x, from.y);
                CGContextAddLineToPoint(context, to.x, to.y);
            }
        } else {
            // NSLog(@"Edge clipped: ");
        }
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);    
}

@end
