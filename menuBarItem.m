//
//  menuBarItem.m
//  puush
//
//  Created by Dean Herbert on 10/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "menuBarItem.h"
#import "menuItemView.h"

@implementation menuBarItem

NSImage *menuIconNormal;

menuItemView *statusView;

@synthesize dropdownMenu;
@synthesize statusItem;

menuBarItem *instance;

+ (menuBarItem*)Instance
{
	return instance;
}

-(void)dealloc
{
    [statusItem release];
	[super dealloc];
}

- (void)awakeFromNib
{
	instance = self;

    menuIconNormal = [[NSImage imageNamed:@"status-icon"] retain];

	// The width and height of the status item
    float width = 24;
    float height = [[NSStatusBar systemStatusBar] thickness];
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
	
    // The status item view's frame
    NSRect viewFrame = NSMakeRect(0, 0, width, height);
	
    // Initialize the status item view
    statusView = [[[menuItemView alloc] initWithFrame:viewFrame] retain];
	
	[statusView setImage:menuIconNormal];
	
	[statusItem setView:statusView];
	
	[statusView setMenu:dropdownMenu];
	
}

- (void)showMenu	
{
	[statusItem popUpStatusItemMenu:dropdownMenu];
}

- (void)hideMenu
{
	[dropdownMenu cancelTracking];
}

- (void)setStatus:(NSString*)status
{
	[statusItem setTitle:status];
}

- (void)clearStatus
{
	[self performSelectorOnMainThread:@selector(setStatus:) withObject:@"" waitUntilDone:YES];

}

- (void)setStatusTemporarily:(NSString*)status
{
	[self setStatus:status];
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearStatus) userInfo:nil repeats:NO];
}

@end
