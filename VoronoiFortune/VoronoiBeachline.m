//
//  VoronoiBeachline.m
//  DrawBoard
//
//  Created by Mikko on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiBeachline.h"
#import "VoronoiMath.h"
#import "VoronoiDefs.h"

@implementation ParabolaBreakpoint
@synthesize location = _lastLocation;
@synthesize lastX = _lastX;
@synthesize edge = _edge;
@synthesize vertex = _vertex;

- (void) dealloc
{
    self.vertex = nil;
    self.edge = nil;
    [super dealloc];
}

@end


@implementation ParabolicArc
@synthesize site = _site;
@synthesize next = _next;
@synthesize prev = _prev;
@synthesize circle = _circle;
@synthesize nextBreak = _nextBreak;
@synthesize breakpoint = _breakpoint;


- (ParabolicArc *)initWithSite:(VoronoiSite *)aSite
{
    self = [super init];
    if (self) {
        self.site = aSite;
        [self.site addParabolicArc:self];
        _breakpoint = [[ParabolaBreakpoint alloc] init];
    }
    return self;
}

- (void)removed
{
    self.site = nil;
    self.circle = nil;
    [_breakpoint release];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self removed];
    [super dealloc];
}
@end


/*
 * Beachline
 * ====================================
 */
@implementation VoronoiBeachLine

- (NSMutableArray *)arcList
{
    if (arcList == nil) {
        arcList = [[NSMutableArray alloc] init];
    }
    return arcList;
}

- (void)debugPrint:(VDouble)scanline
{
    BeachlineIterator_t iterator;
    [self enumerateAtScanline:scanline iterator:&iterator];
    
    while ([self enumerateNext:&iterator] > 0) {
        NSLog(@"  arc %d %p (%Lf, %Lf) site %p (%Lf, %Lf)",
              iterator.currentIndex, iterator.arc, 
              iterator.domainLeft, iterator.domainRight,
              iterator.arc.site, 
              iterator.arc.site.location.x,
              iterator.arc.site.location.y);
    }
}

- (int)findSiteLocatedAbovePoint:(VPoint)newSite
{
    int siteIndex = -1;
    if ([self.arcList count] < 2) {
        siteIndex = [self.arcList count] - 1;
        NSLog(@"BeachLine.%s(%Lf, %Lf) --> %d", __func__, 
              newSite.x, newSite.y, siteIndex);
        return siteIndex;
    }
    
    BeachlineIterator_t iterator;
    [self enumerateAtScanline:newSite.y
                     iterator:&iterator];
    while ([self enumerateNext:&iterator] > 0) {
        if (newSite.x > iterator.domainLeft && 
            newSite.x < iterator.domainRight) {
            siteIndex = iterator.currentIndex;
            break;
        }
    }
    
    NSLog(@"BeachLine.%s(%Lf, %Lf) --> %d", __func__, newSite.x, 
          newSite.y, siteIndex);
    return siteIndex;
}


- (VDouble)breakpointArcA:(ParabolicArc *)leftArc
                     arcB:(ParabolicArc *)rightArc
                 scanline:(VDouble)scanline
{
    VDouble retval;
    QuadraticRoots_t roots = parabolaIntersection(leftArc.site.location, 
                                                  rightArc.site.location,
                                                  scanline);

    if (roots.has_root1 && !roots.has_root2) {
        retval = roots.root1;
    } else if (roots.has_root1 && roots.has_root2) {
        if (roots.root1 > roots.root2) {
            VDouble tmp = roots.root1;
            bool has_tmp = roots.has_root1;
            roots.root1 = roots.root2;
            roots.has_root1 = roots.has_root2;
            roots.root2 = tmp;
            roots.has_root2 = has_tmp;
        }

        VPoint left = leftArc.site.location;
        VPoint right = rightArc.site.location;
        
        if (left.x > right.x && left.y < right.y) {
            retval = roots.root1;
        } else if (left.x < right.x && left.y > right.y) {
            retval = roots.root2;
        } else if (left.x == right.x && left.y < right.y) {
            retval = roots.root1;
        } else if (left.x == right.x && left.y > right.y) {
            retval = roots.root2;
        } else if (left.x < right.x && left.y < right.y) {
            retval = roots.root1;
        } else if (left.x > right.x && left.y > right.y) {
            retval = roots.root2;
        } else {
            NSLog(@"%s, %d, Points coincide. This should never happen.", 
                  __func__, __LINE__);
            NSLog(@"   points: left=(%Lf, %Lf), right=(%Lf, %Lf)",
                  left.x, left.y, right.x, right.y);
            assert(0);
        }
    } else {
        // Parabola doesn't intersect with another
        NSLog(@"%s, %d, Points coincide. This should never happen.", 
              __func__, __LINE__);
        assert(0);
        
    }
    return retval;
}


- (int)enumerateNext:(BeachlineIterator_t *)iterator
{
    int count = [self.arcList count];
    if (iterator == NULL || count == 0) {
        return -1;
    }

    iterator->currentIndex++;
    if (iterator->currentIndex == 0) {
        iterator->arc = [self.arcList objectAtIndex:0];
        iterator->domainLeft = -1.0*DBL_MAX;
    } else {
        iterator->arc = iterator->arc.next;
        iterator->domainLeft = iterator->domainRight;
    }

    if (iterator->arc == nil) {
        return -1;
    }
    
    VDouble breakpoint = DBL_MAX;
    if (iterator->arc.next) {
        breakpoint = [self breakpointArcA:iterator->arc
                                     arcB:iterator->arc.next
                                 scanline:iterator->scanline];
        iterator->arc.breakpoint.location = 
            VPointMake(breakpoint,
                        parabolaAtX(breakpoint,
                                    iterator->arc.site.location, 
                                    iterator->scanline));
    }
    iterator->domainRight = breakpoint;
    iterator->arc.nextBreak = breakpoint;
    return 1;
}


- (void)enumerateAtScanline:(VDouble)scanline 
                   iterator:(BeachlineIterator_t *)iterator
{
    if (iterator == NULL) {
        return;
    }
    iterator->currentIndex = -1;
    iterator->domainLeft = -1.0*DBL_MAX;
    iterator->domainRight = 1.0*DBL_MAX;
    iterator->arc = nil;
    iterator->scanline = scanline;
}


- (int)count
{
    return [self.arcList count];
}


- (ParabolicArc *)siteAtIndex:(int)index
{
    
    return [self.arcList objectAtIndex:index];
}


//
// Usage:
// triple = [self.beachline checkTripleLeftOfSiteAtIndex:i(index + 1)];
//
// index argument is the beachline index of the newly added point. It is
// tested for the rightmost arc in case direction is > 0, else it is 
// tested for the leftmost arc.
//
//     ... <----(-2)--(-1)-- 0 --(+1)--(+2)-----> ...
//   
//                        (index, +1,   +2)
//              (-2,   -1, index)
//
//

- (NSArray *)checkForTripleAtIndex:(int)index atDirection:(int)direction
{
    int left, middle, right;
    
    if ([self.arcList count] < 3) {
        return Nil;
    }
    
    if (direction < 0) {
        left = index - 2;
        middle = index - 1;
        right = index;
    } else if (direction > 0) {
        left = index;
        middle = index + 1;
        right = index + 2;
    } else {
        left = index - 1;
        middle = index;
        right = index + 1;
        
    }
    if (left < 0 || right > [self.arcList count] - 1) {
        NSLog(@"BeachLine.%s(%d, %d) --> Nil", __func__, index, direction);
        return Nil;
    }
    
    ParabolicArc *arc0 = [self.arcList objectAtIndex:left];
    ParabolicArc *arc1 = [self.arcList objectAtIndex:middle];
    ParabolicArc *arc2 = [self.arcList objectAtIndex:right];
    
    if (arc0.site == arc1.site ||
        arc0.site == arc2.site ||
        arc1.site == arc2.site) {
        NSLog(@"BeachLine.%s(%d, %d) --> Nil", __func__, index, direction);
        return Nil;
    }
    
    NSLog(@"BeachLine.%s(%d, %d) --> %p, %p, %p", __func__, index, direction,
          arc0, arc1, arc2);
    return [[[NSArray alloc] initWithObjects:
            arc0, arc1, arc2, nil]
            autorelease];
}

/*
 *   Case: array is empty
 *
 *       arcList: [ ]
 *
 *
 *   Case: only one existing site in array
 *      
 *       arcList: [ old ]
 *       insertObject:new atIndex:0
 *       arcList: [ new | old ]
 *       insertObject:old atIndex:0
 *       arcList: [ old | new | old ]
 *
 *
 *   Case: N elements in array:
 *
 *       arcList: [ 0 | old | 2 ]
 *       insertObject:new atIndex:1 
 *       arcList: [ 0 | new | old | 3 ]
 *       insertObject:old atIndex:1
 *       arcList: [ 0 | old | new | old | 4 ]
 *       
 */

- (int)addNewSite:(VoronoiSite *)site oldArc:(ParabolicArc **)oldArc
{
    int index;
    NSLog(@"BeachLine.%s:%p", __func__, site);
    
    ParabolicArc *left, *middle, *right;
    
    if ([self.arcList count] == 0) {
        ParabolicArc *arc = [[ParabolicArc alloc] initWithSite:site];
        [self.arcList addObject:arc];
        arc.next = nil;
        arc.prev = nil;
        [arc release];
        index = -1;
    } else {        
        index = [self findSiteLocatedAbovePoint:site.location];
        right = [self.arcList objectAtIndex:index];
        VoronoiSite *oldSite = right.site;
        *oldArc = right;
        
        // Split the old point:
        middle = [[ParabolicArc alloc] initWithSite:site];
        [self.arcList insertObject:middle atIndex:index];
        [middle release];
                
        left = [[ParabolicArc alloc] initWithSite:oldSite];
        [self.arcList insertObject:left atIndex:index];
        [left release];

        // Link them in a list:
        middle.prev = left;
        middle.next = right;
        left.next = middle;
        left.prev = right.prev;
        if (right.prev) {
            right.prev.next = left;
        }
        right.prev = middle;
    }
//    [self debugPrint:site.location.y];
    return index + 1;
}


- (int)removeArc:(ParabolicArc *)arc
{
    NSLog(@"BeachLine.%s:%p", __func__, arc);
    int index = [self.arcList indexOfObject:arc];
    assert (index >= 0 && index < [self.arcList count]);

    if (arc.prev) {
        arc.prev.next = arc.next;
    }
    if (arc.next) {
        arc.next.prev = arc.prev;
    }
    arc.prev = nil;
    arc.next = nil;
    
    [self.arcList removeObjectAtIndex:index];
    // [self debugPrint:arc.site.location.y];
    return index;
}


- (void)debugPrintAtScanline:(VDouble)scanline
{
    BeachlineIterator_t iterator;
    ParabolicArc *arc = nil;
    ParabolicArc *next = nil;
    
    [self enumerateAtScanline:scanline iterator:&iterator];
    int i = 0;
    
    NSLog(@"Beachline @ %Lf", scanline);
    while ([self enumerateNext:&iterator] > 0) {
        NSLog(@"   arc %d %p  (%Lf, %Lf)", iterator.currentIndex, iterator.arc,
              iterator.domainLeft, iterator.domainRight);
        if (arc) {
            assert(iterator.arc == next);
            assert(iterator.arc.prev == arc);
        }
        arc = iterator.arc;
        next = arc.next;
        i++;
    }
}

- (NSArray *)arcsAsArray
{
    return (NSArray *)self.arcList;
}

- (void)dealloc
{
    [arcList removeAllObjects];
    [arcList release];
    arcList = nil;
    [super dealloc];
}

@end

