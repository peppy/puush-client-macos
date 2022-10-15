//
//  preferencesWindow.m
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "preferencesWindow.h"
#import <Carbon/Carbon.h>

@implementation preferencesWindow : DBPrefsWindowController

@synthesize generalView;
@synthesize updatesView;
@synthesize accountView;

preferencesWindow *_instance;

-(void) setupToolbar
{
	_instance = self;
	
	[self addView:generalView label:@"General" image:[NSImage imageNamed:@"NSPreferencesGeneral"]];
	[self addView:accountView label:@"Account" image:[NSImage imageNamed:@"NSUser"]];
	[self addView:updatesView label:@"Updates"];
}

- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView
{
	[super crossFadeView:oldView withView:newView];
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[NSApp activateIgnoringOtherApps:YES];
	
	[puushCommon loginWithKnownDetailsDelegate:self];
}

- (void) loginResult:(int)success
{
	[accountView load];
}


+ (preferencesWindow*) Instance
{
	return _instance;
}

@end
