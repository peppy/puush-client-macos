//
//  preferencesGeneral.m
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "preferencesGeneral.h"
#import "puush.h"
#import "BindingManager.h"
#import "preferencesWindow.h"
#import "UKLoginItemRegistry.h"
#import <Carbon/Carbon.h>

@implementation preferencesGeneral : NSView

@synthesize notificationGrowl;
@synthesize notificationSound;
@synthesize notificationClipboard;
@synthesize notificationBrowser;

@synthesize generalIconInDock;
@synthesize generalStartAtStartup;

@synthesize binding1;
@synthesize binding2;
@synthesize binding3;

@synthesize activeBindingButton;

- (void)load
{
	activeBindingButton = nil;

	[generalIconInDock setState:[[puush config] boolForKey:@"DockIcon"]];
	[generalStartAtStartup setState:[UKLoginItemRegistry indexForLoginItemWithPath:[[NSBundle mainBundle] bundlePath]] > 0];

	[notificationGrowl setState:![[puush config] boolForKey:@"NotificationGrowlDisabled"]];
	[notificationSound setState:![[puush config] boolForKey:@"NotificationSoundDisabled"]];
	[notificationClipboard setState:![[puush config] boolForKey:@"NotificationClipboardDisabled"]];
	[notificationBrowser setState:[[puush config] boolForKey:@"NotificationBrowser"]];

	[[puush bindingManager] initializeBindings];

	[binding1 setState:0];
	[binding1 setTag:BI_SelectArea];
	[binding1 setTitle:[[puush bindingManager] getStringRepresentationForBinding:BI_SelectArea]];

	[binding2 setState:0];
	[binding2 setTag:BI_FullscreenScreenshot];
	[binding2 setTitle:[[puush bindingManager] getStringRepresentationForBinding:BI_FullscreenScreenshot]];

	[binding3 setState:0];
	[binding3 setTag:BI_UploadFile];
	[binding3 setTitle:[[puush bindingManager] getStringRepresentationForBinding:BI_UploadFile]];
}

- (IBAction)toggleStartAtStartup:(id)sender
{
	NSButton *button = (NSButton*)sender;

	[puush startAtStartup:button.state];
}

- (IBAction)toggleDockIcon:(id)sender
{
	NSButton *button = (NSButton*)sender;
	[[puush config] setBool:button.state forKey:@"DockIcon"];
	[[puush config] synchronize];

	if (button.state)
		[[puush Instance] displayDockIconIfRequired];
	else {
		[puush Restart];
	}

}

- (IBAction)toggleGrowl:(id)sender
{
	NSButton *button = (NSButton*)sender;
	[[puush config] setBool:!button.state forKey:@"NotificationGrowlDisabled"];
	[[puush config] synchronize];
}

- (IBAction)toggleSound:(id)sender
{
	NSButton *button = (NSButton*)sender;
	[[puush config] setBool:!button.state forKey:@"NotificationSoundDisabled"];
	[[puush config] synchronize];
}

- (IBAction)toggleClipboard:(id)sender
{
	NSButton *button = (NSButton*)sender;
	[[puush config] setBool:!button.state forKey:@"NotificationClipboardDisabled"];
	[[puush config] synchronize];
}

- (IBAction)toggleBrowser:(id)sender
{
	NSButton *button = (NSButton*)sender;
	[[puush config] setBool:button.state forKey:@"NotificationBrowser"];
	[[puush config] synchronize];
}

- (IBAction)bindingButtonClicked:(id)sender
{
	[self load];

	NSButton *thisButton = (NSButton*)sender;

	activeBindingButton = thisButton;

	[thisButton setState:1];
	[thisButton setTitle:@"Press some keys..."];
}

- (IBAction)bindingResetButtonClicked:(id)sender
{
	NSButton *thisButton = (NSButton*)sender;

	[[puush bindingManager] setBindingFor:[thisButton tag] withCombination:KeyCombination(0,0)];
	[self load];
}


-(BOOL) performKeyEquivalent:(NSEvent *)event
{
	if (([event modifierFlags] & NSCommandKeyMask) > 0 && [event keyCode] == kVK_ANSI_W)
	{
		[[preferencesWindow Instance] close];
		return true;
	}

	if ([event keyCode] == kVK_Escape)
	{
		[self load];
		return true;
	}

	if (activeBindingButton == nil)
	{
		return [super performKeyEquivalent:event];
	}

	int keyCode = [event keyCode];

	BOOL shift = ([event modifierFlags] & NSShiftKeyMask) > 0;
	BOOL cmd = ([event modifierFlags] & NSCommandKeyMask) > 0;
	BOOL ctrl = ([event modifierFlags] & NSControlKeyMask) > 0;
	BOOL option = ([event modifierFlags] & NSAlternateKeyMask) > 0;

	int modifier = 0;

	if (shift) modifier |= shiftKey;
	if (cmd) modifier |= cmdKey;
	if (ctrl) modifier |= controlKey;
	if (option) modifier |= optionKey;

	[[puush bindingManager] setBindingFor:activeBindingButton.tag withCombination:KeyCombination(keyCode,modifier)];

	[self load];

	return true;
}

@end
