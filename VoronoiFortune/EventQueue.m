//
//  EventQueue.m
//  DrawBoard
//
//  Created by Mikko on 02/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventQueue.h"
#import "VoronoiDefs.h"

static
VDouble compareLocation(VPoint p1, VPoint p2)
{
    if (p1.y != p2.y) {
        return p1.y - p2.y;
    } else {
        return p1.x - p2.x;
    }
}


@implementation EventQueue

- (EventQueue *)init
{
    self = [super init];
    if (self) {
        _heap = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)debugPrint
{
    int i = 0;
    for (id <VoronoiEvent> event in _heap) {
        NSLog(@"%d: event %@ (%Lf, %Lf)", i, event, 
              event.location.x, event.location.y);
        i++;
    }    
}

- (void)checkSanity
{
    NSLog(@"Checking Event Queue heap sanity...");

    if ([_heap count] == 0) {
        return;
    }
    
    // [self debugPrint];
    
    id <VoronoiEvent> top = [_heap objectAtIndex:0];
    for (id <VoronoiEvent> event in _heap) {
        if (top.location.y > event.location.y) {
            NSLog(@"Event queue heap sanity corrupted. %p (%Lf, %Lf) > %p (%Lf, %Lf)",
                  top, top.location.x, top.location.y,
                  event, event.location.x, event.location.y);
        }
        assert(top.location.y <= event.location.y);
    }    
}

- (void)insertInEventQueue:(id <VoronoiEvent>)event
{
//    NSLog(@"%s event=%@", __func__, event);
    id <VoronoiEvent> parent;
    
    if (event == nil) {
        return;
    }
    
    // TODO: Need to reshuffle for priority queue... e the newly 
    // inserted event up into its correct priority.
    [_heap addObject:event];
    int ind_new = [_heap count];
    if (ind_new < 2) {
        return;
    }
    int ind_parent = floor(ind_new/2);
    @try {
        parent = [_heap objectAtIndex:ind_parent - 1];
    }
    @catch (NSException *exception) {
        parent = nil;
    }
    
    while (parent && compareLocation(event.location, parent.location) < 0) {
        // New event is nearer to scanline than its parent, therefore 
        // bubble up
        [_heap exchangeObjectAtIndex:ind_new - 1 withObjectAtIndex:ind_parent - 1];
        ind_new = ind_parent;
        ind_parent = floor(ind_new/2);
        @try {
            parent = [_heap objectAtIndex:ind_parent - 1];
        } 
        @catch (NSException *exception) {
            parent = nil;
        }
    }
    
    // [self checkSanity];
    
}


- (id <VoronoiEvent>)getSmallerSubtreeAtIndex:(int)index 
                                              subIndex:(int *)i_sub
{
    id <VoronoiEvent> left;
    id <VoronoiEvent> right;
    id <VoronoiEvent> sub;
    
    int i_left = index*2;
    int i_right = index*2 + 1;
    
    @try {
        left = [_heap objectAtIndex:i_left - 1];
    }
    @catch (NSException *exception) {
        *i_sub = -1;
        return Nil;
    }
    
    @try {
        right = [_heap objectAtIndex:i_right - 1];
    }
    @catch (NSException *exception) {
        *i_sub = i_left;
        return left;
    }
    
    if (compareLocation(left.location, right.location) < 0) {
        // left < right
        *i_sub = i_left;
        sub = left;
    } else {
        // left >= right
        *i_sub = i_right;
        sub = right;
    }
    return sub;
}

- (void)bubbleDown:(int)index
{
    int subIndex = -1;
    id <VoronoiEvent> node = [_heap objectAtIndex:index - 1];
    id <VoronoiEvent> subNode = [self getSmallerSubtreeAtIndex:index 
                                                      subIndex:&subIndex];
    while (subNode && compareLocation(node.location, subNode.location) > 0) {
        [_heap exchangeObjectAtIndex:index - 1 withObjectAtIndex:subIndex - 1];
        index = subIndex;
        subNode = [self getSmallerSubtreeAtIndex:index subIndex:&subIndex];
    }
}

- (void)bubbleUp:(int)index
{
    id <VoronoiEvent> node = [_heap objectAtIndex:index - 1];

    int parentIndex = index/2;
    id <VoronoiEvent> parent = [_heap objectAtIndex:parentIndex - 1];
    
    while (index > 1 && compareLocation(parent.location, node.location) > 0) {
        [_heap exchangeObjectAtIndex:index - 1 
                   withObjectAtIndex:parentIndex - 1];
        index = parentIndex;
        parentIndex = index/2;
        parent = [_heap objectAtIndex:parentIndex - 1];
    }
}

- (id <VoronoiEvent>)popFromEventAtIndex:(int)index
{
    // 1. Move first element in front.
    int i_last = [_heap count];
    id <VoronoiEvent> last = [_heap objectAtIndex:i_last - 1];
    id <VoronoiEvent> old = [_heap objectAtIndex:index - 1];
    [_heap exchangeObjectAtIndex:index - 1 
               withObjectAtIndex:i_last - 1];
    
    // 2. Remove the old object from queue:
    [_heap removeLastObject];
    if (last == old) {
        return old;
    }
   
    i_last--;
    
    // 3. Bubble up or down:
//    NSLog(@"4/2=%d, 5/2=%d, 4>>1=%d, 5>>1=%d", 4/2, 5/2, 4>>1, 5>>1);

    int subIndex = -1;
    id <VoronoiEvent> node = last;
    id <VoronoiEvent> subNode = [self getSmallerSubtreeAtIndex:index 
                                                      subIndex:&subIndex];
    if (subNode && compareLocation(node.location, subNode.location) > 0) {
        [self bubbleDown:index];
    } else if (index > 1) {
        [self bubbleUp:index];
    }
    
    return old;
}

- (id <VoronoiEvent>)getEvent
{
    return [_heap objectAtIndex:0];
}

- (void)removeEvent:(id <VoronoiEvent>)event
{
//    NSLog(@"%s event=%@", __func__, event);
    int i_old = [_heap indexOfObject:event] + 1;
    [self popFromEventAtIndex:i_old];
//    [self checkSanity];
}

- (NSArray *)eventsAsArray
{
    return (NSArray *)_heap;
}

- (void) dealloc
{
    [_heap removeAllObjects];
    [_heap release];
    _heap = nil;
    [super dealloc];
}

@end
