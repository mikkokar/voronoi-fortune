//
//  PointEditorViewController.m
//  VoronoiFortune
//
//  Created by Mikko on 16/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PointEditorViewController.h"
#import "VoronoiViewController.h"

@implementation PointEditorViewController
@synthesize pointEditorView = _pointEditorView;
@synthesize tapRecognizer = _tapRecognizer;

- (void)dealloc
{
    [_pointSet removeAllObjects];
    [_pointSet release];
    [_pointEditorView release];
    [_tapRecognizer release];
    [super dealloc];
}

- (IBAction)screenTapped:(id)sender {
    CGPoint location = [sender locationInView:self.pointEditorView];
    NSLog(@"%s point=(%f, %f)", __func__, location.x, location.y);
    [_pointSet addObject:[NSValue valueWithCGPoint:location]];

    PointEditorView *myView = (PointEditorView *)self.view;
    [myView newSiteAt:location];
}

- (IBAction)clearPoints:(id)sender {
    [_pointSet removeAllObjects];
    [self.pointEditorView setNeedsDisplay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"StartVoronoiAlgorithm"]) {
        VoronoiViewController *vc = segue.destinationViewController;
        vc.voronoiSites = self.pointSet;
    }
}

- (NSSet *)pointSet
{
    return (NSSet *)_pointSet;
}

- (id)init
{
    UIView *v = [[PointEditorView alloc] init];
    self.view = v;
    [v release];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)doneClicked:(id)sender {
    NSLog(@"%s", __func__);
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
    NSLog(@"%s", __func__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pointEditorView = (PointEditorView *)self.view;
    self.pointEditorView.controller = self;
    
    _pointSet = [[NSMutableSet alloc] init];
    self.title = @"Add/Edit Points";
}


- (void)viewDidUnload
{
    [self setView:nil];
    [self setPointEditorView:nil];
    [self setTapRecognizer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
