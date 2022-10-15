//
//  preferenceUpdates.m
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "preferencesUpdates.h"
#import "puush.h"
#import <Carbon/Carbon.h>
#import "preferencesWindow.h"

@implementation preferencesUpdates

@synthesize lastUpdated;

- (void)load
{
	NSString *lastUpdateString = [[puush config] stringForKey:@"LastUpdated"];
	
	NSDate *date = [[[puush Instance] updater] lastUpdateCheckDate];
	
	if (date == nil)
		lastUpdateString = @"Never";
	else
		lastUpdateString = [date descriptionWithLocale:[NSLocale currentLocale]];

	[lastUpdated setStringValue:lastUpdateString];
}

-(BOOL) performKeyEquivalent:(NSEvent *)event
{
	if (([event modifierFlags] & NSCommandKeyMask) > 0 && [event keyCode] == kVK_ANSI_W)
	{
		[[preferencesWindow Instance] close];
		return true;
	}
	
	return [super performKeyEquivalent:event];
}


// Sent when a valid update is not found.
- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
	[self load];
}

// Sent immediately before installing the specified update.
- (void)updater:(SUUpdater *)updater willInstallUpdate:(SUAppcastItem *)update
{
	[self load];
}

@end
