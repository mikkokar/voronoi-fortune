//
//  VoronoiViewController.m
//  VoronoiFortune
//
//  Created by Mikko on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VoronoiViewController.h"
#import "VoronoiFortuneAlgorithm.h"
#import "VoronoiView.h"

@implementation VoronoiViewController

@synthesize algorithm;
@synthesize voronoiSites;
@synthesize currentEvent;
@synthesize nextEvent;
@synthesize state;
@synthesize scanline;

- (id)init
{
    [super init];
    NSLog(@"%s", __func__);
    return self;
}

- (void)initializeAlgorithm
{
    NSLog(@"%s", __func__);
    self.scanline = 0.0;    
    self.currentEvent = nil;
    self.nextEvent = nil;
    self.state = VORC_DIAGRAM_EMPTY;    
}

- (void)freeResources
{
    NSLog(@"%s", __func__);
    self.algorithm = nil;
    self.currentEvent = nil;
    self.nextEvent = nil;
}

- (void)dealloc
{
    self.voronoiSites = nil;
    [self freeResources];
    [super dealloc];
}

- (VoronoiView *)voronoiView
{
    return (VoronoiView *)self.view;
}

- (bool)startAlgorithm
{
    if (self.algorithm != nil) {
        return false;
    }
    
    VoronoiFortuneAlgorithm *a = [[VoronoiFortuneAlgorithm alloc] 
                                  init];
    if (!a) {
        return false;
    }
    self.algorithm = a;
    [a release];
    [self.algorithm interactiveVoronoiForPoints:[self.voronoiSites
                                                 allObjects]];
    return true;
}

- (bool)getNextEvent
{
    bool gotEvent = [self.algorithm nextEvent];
    if (gotEvent) {
        [self.voronoiView updateContent];
    } else {
        self.algorithm = nil;
    }
    return gotEvent;
}

- (CGFloat)scanlineStopLocation
{
    // MK TODO: We should put some proper code to
    // extend the unconnected edges all the way to
    // bottom of the screen.
    //
    // We can do this by going through the scanline, and computing
    // the site distance to end of the screen. The scanline needs to 
    // be at least twice the distance from the topmost site to the
    // end of the screen.
    // 
    // In practice, the first arc would always have emereged from 
    // the first (ie topmost) site. Therefore we can just take the
    // first arc from the beachline, and compute its distance from
    // bottom of the screen. The scanline must be located twice
    // this distance.
    
    CGFloat screenHeight = self.view.bounds.size.height;
    ParabolicArc *arc = [self.algorithm.beachline siteAtIndex:0];
    return 2.0*screenHeight - arc.site.location.y;    
}

- (IBAction)nextEvent:(id)sender {
    NSLog(@"%s", __func__);
    if (self.state == VORC_DIAGRAM_READY) {
        return;
    }
    if (self.state == VORC_DIAGRAM_EMPTY) {
        [self startAlgorithm];
    }
    self.state = VORC_PAUSED;
    
    bool gotEvent = [self.algorithm nextEvent];
    if (gotEvent == false) {
        //if (self.scanline < self.view.bounds.size.height) {
        if (self.scanline < [self scanlineStopLocation]) {
            self.scanline = (VDouble)[self scanlineStopLocation];   
        }
        //}
        self.nextEvent = nil;
        self.state = VORC_DIAGRAM_READY;
        [self.voronoiView updateContent];
        return;
    }
    self.currentEvent = [self.algorithm.pastEvents lastObject];
    self.scanline = self.currentEvent.location.y;
    self.nextEvent = [self.algorithm peekNextEvent];
    [self.voronoiView updateContent];
}

        
- (void)moveScanline:(NSTimer *)timer
{
    if (self.state == VORC_PLAYING) {
        if (self.nextEvent) {
            if (self.scanline + 1.5 < self.nextEvent.location.y) {
                self.scanline += 1.5;
            } else {
                bool gotEvent = [self.algorithm nextEvent];
                if (gotEvent) {
                    self.currentEvent = [self.algorithm.pastEvents lastObject];
                    self.scanline = self.currentEvent.location.y;
                    self.nextEvent = [self.algorithm peekNextEvent];
                }
            }
        } else {
            // All events processed
            if (self.scanline < [self scanlineStopLocation]) {
                self.scanline += 1.0;
            } else {
                self.nextEvent = nil;
                [_timer invalidate];
                self.state = VORC_DIAGRAM_READY;
                NSLog(@"Playback stopped.");
            }
        }
        [self.voronoiView updateContent];
        // [self.view setNeedsDisplay];
    }
}


- (IBAction)play:(id)sender {
    if (self.state == VORC_DIAGRAM_EMPTY) {
        [self startAlgorithm];
        _timer = [NSTimer
                  scheduledTimerWithTimeInterval:0.05
                                          target:self 
                                        selector:@selector(moveScanline:) 
                                        userInfo:nil 
                                        repeats:true];
        self.currentEvent = nil;
        self.nextEvent = [self.algorithm peekNextEvent];
        if (self.nextEvent == nil) {
            // no events!
            [_timer invalidate];
            self.state = VORC_DIAGRAM_READY;
            return;
        }
    } else if (self.state == VORC_PAUSED) {
        _timer = [NSTimer
                  scheduledTimerWithTimeInterval:0.05
                                          target:self 
                                        selector:@selector(moveScanline:) 
                                        userInfo:nil 
                                        repeats:true];
    }
    self.state = VORC_PLAYING;
}


- (IBAction)pause:(id)sender {
    if (self.state == VORC_PLAYING) {
        [_timer invalidate];
        self.state = VORC_PAUSED;
    } else if (self.state == VORC_PAUSED) {
        [self play:sender];
    }
}



- (IBAction)panEvent:(UIPanGestureRecognizer *)sender {
    CGPoint pan = [sender locationInView:self.view];
    NSLog(@"Pan event point=(%f, %f)", pan.x, pan.y);
    if (self.state == VORC_DIAGRAM_EMPTY) {
        [self startAlgorithm];
        self.currentEvent = nil;
        self.nextEvent = [self.algorithm peekNextEvent];
        if (self.nextEvent == nil) {
            // no events!
            self.state = VORC_DIAGRAM_READY;
            return;
        }
    }
    
    if (pan.y < scanline) {
        return;
    }
   
    if (self.state == VORC_PLAYING) {
        [self pause:nil];
    }
    
    while (self.nextEvent && self.nextEvent.location.y < pan.y) {
        bool gotEvent = [self.algorithm nextEvent];
        if (gotEvent) {
            self.currentEvent = [self.algorithm.pastEvents lastObject];
            self.scanline = self.currentEvent.location.y;
            self.nextEvent = [self.algorithm peekNextEvent];
        }
    }
    
    self.scanline = pan.y;
    
    if (pan.y >= self.view.bounds.origin.y +
        self.view.bounds.size.width)
    {
        [self play:nil];
    }
    [self.voronoiView updateContent];
}


- (IBAction)reload:(id)sender {
    NSLog(@"%s", __func__);
    [self pause:nil];
    [self freeResources];
    [self initializeAlgorithm];
    [self.voronoiView setNeedsDisplay];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%s", __func__);
    self.voronoiView.controller = self;
    self.voronoiView.showCircles = false;
    [self initializeAlgorithm];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self pause:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
    [self play:nil];
}

- (void):(BOOL)animated
{
    NSLog(@"%s", __func__);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
