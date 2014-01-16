//
//  EventQueue.h
//  DrawBoard
//
//  Created by Mikko on 02/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoronoiCommon.h"


@interface EventQueue : NSObject {
    @private
    NSMutableArray *_heap;
}

- (void)insertInEventQueue:(id <VoronoiEvent>)event;
- (id <VoronoiEvent>)getEvent;
- (NSArray *)eventsAsArray;
- (void)removeEvent:(id <VoronoiEvent>)event;

@end
