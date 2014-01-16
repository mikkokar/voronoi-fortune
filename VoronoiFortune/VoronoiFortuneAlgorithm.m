//
//  VoronoiFortuneAlgorithm.m
//  DrawBoard
//
//  Created by Mikko on 01/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiFortuneAlgorithm.h"
#import "VoronoiMath.h"
#include "VoronoiDefs.h"

@implementation VoronoiFortuneAlgorithm
@synthesize evQueueCicleCookie = _evQueueCircleCookie;

- (VoronoiDiagram *)diagram
{
    if (_diagram == nil) {
        _diagram = [[VoronoiDiagram alloc] init];
    }
    return _diagram;
}


- (NSArray *)futureEvents
{
    return [_eventQueue eventsAsArray];
}


- (VoronoiBeachLine *)beachline
{
    if (_beachline == nil) {
        _beachline = [[VoronoiBeachLine alloc] init];
    }
    return _beachline;
}


- (VoronoiCircle *)isCircleAlreadyCreated:(NSArray *)triple
                                  current:(VoronoiCircle *)circle
{
    NSSet *newSet;
    VoronoiSite *site0 = [[triple objectAtIndex:0] site];
    VoronoiSite *site1 = [[triple objectAtIndex:1] site];
    VoronoiSite *site2 = [[triple objectAtIndex:2] site];
    
    newSet = [[NSSet alloc] initWithObjects:site0, site1, site2, nil];
 
    id <VoronoiEvent> event;
    for (event in self.futureEvents) {
        if ([event isKindOfClass:[VoronoiCircle class]]) {
            VoronoiCircle *otherCircle = (VoronoiCircle *)event;
            NSSet *otherSet = [otherCircle sitesAsSet];
            if ([newSet isEqualToSet:otherSet]) {
                [newSet release];
                return otherCircle;
            }
        }
    }
    if (circle) {
        NSSet *otherSet = [circle sitesAsSet];
        if ([newSet isEqualToSet:otherSet]) {
            [newSet release];
            return circle;
        }
    }
    [newSet release];
    return nil;
}



- (VoronoiCircle *)allocCircleEvent:(int)index 
                        atDirection:(int)direction
                            current:(VoronoiCircle *)circle
                           scanline:(VDouble)scanline
{
    VoronoiCircle *newCircle = nil;
    NSArray *triple;
    triple = [self.beachline checkForTripleAtIndex:index
                                       atDirection:direction];
    if (triple) {
        ParabolicArc *arc0 = [triple objectAtIndex:0];
        ParabolicArc *arc1 = [triple objectAtIndex:1];
        ParabolicArc *arc2 = [triple objectAtIndex:2];
        
        // Ensure that sites are distinct:
        if (arc0.site == arc1.site || arc0.site == arc2.site ||
            arc1.site == arc2.site) {
            // NSLog(@"Is not circle event. Sites %p, %p, %p were
            // not distinct", arc0.site, arc1.site, arc2.site);
            return nil;
        }
        
        // Ensure that circle event does not already exist:
        // TBD.
        VoronoiCircle *otherCircle = [self isCircleAlreadyCreated:(NSArray *)triple 
                                                               current:circle]; 
        if (otherCircle) {
            // NSLog(@"Not circle event. Another circle %p already exists",
            //  otherCircle);
            return nil;
        }
        
        VPoint center;
        VDouble radius;
        ParabolicArc *left = arc1.prev;
        ParabolicArc *middle = arc1;
        ParabolicArc *right = arc1.next;
        bool ok = circleFormula(left.site.location, 
                                middle.site.location, 
                                right.site.location, 
                                &center, &radius);
        if (!ok) {
            // Three given site locations do not form a circle.
            // NSLog(@"Three given site locations do not form a circle.");
            // NSLog(@"   left=%p site=(%f, %f), "
            //       "middle=%p site=(%f, %f), "
            //       "right=%p site=(%f, %f)",
            //       left, left.site.location.x,
            //       left.site.location.y,
            //       middle, middle.site.location.x,
            //       middle.site.location.y,
            //       right, right.site.location.x, 
            //       right.site.location.y
            // );
            return Nil;
        }
        
        // Ensure that circle does intersect with scanline:
        if (center.y + radius < scanline) {
            NSLog(@"Not circle event. Doesn't intersect with scanline");
            return nil;
        }
        
        VDouble break1 = [self.beachline breakpointArcA:arc0 
                                                   arcB:arc1 
                                               scanline:center.y + radius];
        VDouble break2 = [self.beachline breakpointArcA:arc1
                                                   arcB:arc2 
                                               scanline:center.y + radius];
        VDouble gap = fabs(break1 - break2);
        VDouble roundoff = 1.0;
       
        if (gap > roundoff) {
            // Breakpoints don't converge. Therefore not a circle event.
            NSLog(@"Not circle event. Breakpoints do not converge.");
            NSLog(@"    break1=%Lf break2=%Lf gap=%Lf sizeof(CGFloat)=%lu.",
                  break1, break2, gap, sizeof(CGFloat));
            // was: [newCircle release];
            return nil;
        }
        
        newCircle = [[[VoronoiCircle alloc] initWithCenter:center 
                                                 andRadius:radius]
                     autorelease];
        newCircle.arc = arc1;
        arc1.circle = newCircle;
    }      
    return newCircle;
}


/**
Handle circle event
 
 1a. Delete leaf Y that represents the disappearing arc A from beachline.
     Update breakpoint tuples at the internal nodes. Perform reblancing 
     operations on beachline if necessary. 
 
 1b. Delete all circle events involving A from Q. These can be found using 
     the pointers from the predecessor and the successor of Y in beachline. 
     (The circle event where A is the middle arc is currently being handled,
     and has already been deleted from Q.)
 
        COMMENT: Delete all circle events involving Pj from Q.
 
                 A site must store a list of circle events it contributes to. 
                 Walk this list and remove all associated circle events:
 
                 for ce Pj.circleEvents:
                     Q.remove(ce)
                     ce.remove()
 
 2. Add the center of the circle causing the event as a vertex record
    to the doubly-connected edge list D storing the Voronoi diagram
    under construction. Create two half-edge records corresponding to the
    new breakpoint of the beach line. Set the pointers between them appropriately.
    Attach the three new records to the half-edge records that end at the vertex.
 
 3. Check the new triple of consecutive arcs that has the former left neighbour
    of A as its middle arc to see if the two breakpoints of the triple converge.
    If so, insert the corresponding circle event into Q, and set pointers between
    the new circle event in Q and the corresponding leaf of beachline. Do the same
    for the triple where the former right neighbour is the middle arc.

                               was:
                                Pj
                               \ /
        COMMENT:  ... | Ph | Pi | Pk | Pl |   | ...
 
 */

- (void)replaceInfinityVertexForEdge:(VoronoiEdge *)edge
                              withBp:(ParabolaBreakpoint *)breakpoint
                          withVertex:(VoronoiVertex *)vertex
{
    if (edge.src_vertex.infinity && edge.src_vertex.data == breakpoint) {
        edge.src_vertex.data = nil;
        edge.src_vertex = vertex;
    } else if (edge.dst_vertex.infinity && edge.dst_vertex.data == breakpoint) {
        edge.dst_vertex.data = nil;
        edge.dst_vertex = vertex;
    } else {
        assert(0);
    }
}


- (void)handleCircleEvent:(VoronoiCircle *)circle
{
    VoronoiCircle *oldCircle;

    // Create a Voronoi Vertex:
    VoronoiVertex *vertex = [self.diagram getNewVertex];
    vertex.location = CGPointFromVPoint(circle.center);

    // Connect the two edges to newly created edge:
    VoronoiEdge *edgeLeft = (VoronoiEdge *)circle.arc.prev.breakpoint.edge;
    VoronoiEdge *edgeRight = (VoronoiEdge *)circle.arc.breakpoint.edge;
    
    [self replaceInfinityVertexForEdge:edgeLeft 
                                withBp:circle.arc.prev.breakpoint 
                            withVertex:vertex];
    [self replaceInfinityVertexForEdge:edgeRight 
                                withBp:circle.arc.breakpoint 
                            withVertex:vertex];
    
    // Create a new edge and associate it with newly created vertex and breakpoint:
    VoronoiEdge *newEdge = [self.diagram getNewEdge];
    vertex.edge = newEdge;
    newEdge.src_vertex = vertex;

    newEdge.dst_vertex = [self.diagram getNewVertex];
    newEdge.dst_vertex.data = circle.arc.prev.breakpoint;
    circle.arc.prev.breakpoint.edge = newEdge;
    
    
    // Remove circle from event queue and invalidate any other circles
    // that are associated to this disappearing arc.
    oldCircle = circle.arc.prev.circle;
    if (oldCircle) {
        oldCircle.arc = nil;
        [_eventQueue removeEvent:oldCircle];
    }
    circle.arc.prev.circle = nil;
   
    oldCircle = circle.arc.next.circle;
    if (oldCircle) {
        oldCircle.arc = nil;
        [_eventQueue removeEvent:oldCircle];
    }
    circle.arc.next.circle = nil;
    
    int index = [self.beachline removeArc:circle.arc];
    circle.arc.circle = nil;
    circle.arc = nil;
    
    VoronoiCircle *newCircle;
    newCircle = [self allocCircleEvent:index atDirection:0
                               current:circle
                              scanline:circle.location.y];
    [_eventQueue insertInEventQueue:newCircle];
    // [newCircle release];
    _lastCircle1 = newCircle;
    
    newCircle = [self allocCircleEvent:(index - 1) atDirection:0
                               current:circle
                              scanline:circle.location.y];
    [_eventQueue insertInEventQueue:newCircle];
    // [newCircle release];
    _lastCircle2 = newCircle;
}


- (void)handleSiteEvent:(VoronoiSite *)site
{
    //NSLog(@"Site Event: %p (%f, %f)", site, site.location.x, site.location.y);
    //[_beachline debugPrintAtScanline:site.location.y];
    
    ParabolicArc *oldArc = nil;
    
    if ([self.beachline count] == 0) {
        [self.beachline addNewSite:site oldArc:&oldArc];
        return;
    }
    
    int index = [self.beachline addNewSite:site oldArc:&oldArc];

    // Add new edge:
    //
    // During diagram construction, edge.data property contains a reference
    // to the parabolic arc that is tracking an unconnected voronoi edge.
    // Note, if an edge is connected to an existing voronoi site (after circle
    // event, the self.data property holds a reference to the arc on the *left*
    // of tracked voronoi edge.

    ParabolicArc *newArc = [self.beachline siteAtIndex:index];
    VoronoiEdge *edgeNew = [self.diagram getNewEdge];

    newArc.prev.breakpoint.edge = edgeNew;
    edgeNew.src_vertex =  [self.diagram getNewVertex];
    edgeNew.src_vertex.data = newArc.prev.breakpoint;
    
    newArc.breakpoint.edge = edgeNew;
    edgeNew.dst_vertex =  [self.diagram getNewVertex];
    edgeNew.dst_vertex.data = newArc.breakpoint;
    
    // To compute a location, compute parabolaAtX using X coordinate 
    // of a new site, 
    CGFloat pointY = (CGFloat)parabolaAtX(site.location.x,
                                          oldArc.site.location,
                                          site.location.y);
    edgeNew.point = CGPointMake((CGFloat)site.location.x, pointY);

    
    if (oldArc.circle) {
        [_eventQueue removeEvent:oldArc.circle];
        [oldArc.circle falseAlarm];
    }
    
    VoronoiCircle *newCircle;
    newCircle = [self allocCircleEvent:index atDirection:-1 
                               current:nil
                              scanline:site.location.y];
    if (newCircle) {
        [_eventQueue insertInEventQueue:newCircle];
        _evQueueCircleCookie++;
    }
    // [newCircle release];
    _lastCircle1 = newCircle;
    
    
    newCircle = [self allocCircleEvent:index atDirection:+1
                               current:nil
                              scanline:site.location.y];
    if (newCircle) {
        [_eventQueue insertInEventQueue:newCircle];
        _evQueueCircleCookie++;
    }
    // [newCircle release];
    _lastCircle2 = newCircle;
}


- (VDouble)scanline
{
    return _lastScanline;
}


- (VoronoiCircle *)circle1
{
    VoronoiCircle *tmp = _lastCircle1;
    _lastCircle1 = nil;
    return tmp;
}


- (VoronoiCircle *)circle2
{
    VoronoiCircle *tmp = _lastCircle2;
    _lastCircle2 = nil;
    return tmp;
}


- (NSMutableArray *)pastEvents
{
    return _pastEvents;
}


- (void)populateEventQueue:(NSArray *)points
{
    int i = 0;
    for (NSValue *val in points) {
        CGPoint location = [val CGPointValue];
        VoronoiSite *site = [[VoronoiSite alloc]
                             initWithLocation:VPointFromCGPoint(location)];
        [_eventQueue insertInEventQueue:site];
        [site release];
        i++;
    }
}


- (void)voronoiForPoints:(NSArray *)points
{
    _eventQueue = [[EventQueue alloc] init];
    [self populateEventQueue:points];
    while ([[_eventQueue eventsAsArray ] count] > 0) {
        id event = [_eventQueue getEvent];
        if ([event isKindOfClass:[VoronoiSite class]]) {
            VoronoiSite *site = (VoronoiSite *)event;
            [self handleSiteEvent:site];
            
        } else if ([event isKindOfClass:[VoronoiCircle class]]) {
            VoronoiCircle *circle = (VoronoiCircle *)event;
            [self handleCircleEvent:circle];
        }
        [_eventQueue removeEvent:event];
    }
}


- (bool)nextEvent
{
    _lastCircle1 = nil;
    _lastCircle2 = nil;
    _lastScanline = 0.0;
    
    if ([[_eventQueue eventsAsArray] count] > 0) {
        id event = [_eventQueue getEvent];
        [_pastEvents addObject:event];
        if ([event isKindOfClass:[VoronoiSite class]]) {
            VoronoiSite *site = (VoronoiSite *)event;
            [self handleSiteEvent:site];
            _lastScanline = site.location.y;
        } else if ([event isKindOfClass:[VoronoiCircle class]]) {
            VoronoiCircle *circle = (VoronoiCircle *)event;
            [self handleCircleEvent:circle];
            _lastScanline = circle.location.y;
            _evQueueCircleCookie++;
        }
        //[self.diagram debugPrint];
        [_eventQueue removeEvent:event];  // TODO: inefficient, we can always
                                          // remove the first one.
        return true;
    }
    return false;
}

- (id <VoronoiEvent>)peekNextEvent
{
    if ([[_eventQueue eventsAsArray] count] > 0) {
        id event = [[_eventQueue eventsAsArray] objectAtIndex:0];
        return event;
    }
    return  nil;
}

- (void)interactiveVoronoiForPoints:(NSArray *)points
{
    _eventQueue = [[EventQueue alloc] init];
    _evQueueCircleCookie = 0;
    _pastEvents = [[NSMutableArray alloc] init];
    [self populateEventQueue:points];
}

- (void)releaseObjects
{
    [_diagram release];
    _diagram = nil;

    [_beachline release];
    _beachline = nil;

    [_eventQueue release];
    _eventQueue = nil;

    [_pastEvents removeAllObjects];
    [_pastEvents release];
    _pastEvents = nil;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self releaseObjects];
    [super dealloc];
}

@end
