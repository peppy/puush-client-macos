//
//  preferencesAccount.m
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "preferencesAccount.h"
#import "ASIFormDataRequest.h"
#import "puush.h"
#import "puushCommon.h"
#import "preferencesWindow.h"
#import <Carbon/Carbon.h>

@implementation preferencesAccount : NSView

@synthesize usernameInput;
@synthesize passwordInput;

@synthesize loginScreen;
@synthesize accountInfoScreen;
@synthesize usernameDisplay;
@synthesize keyDisplay;
@synthesize expiryDisplay;
@synthesize typeDisplay;
@synthesize usageDisplay;

@synthesize devCheckbox;

@synthesize loginButton;

-(void) updateButtonEnabledStatus
{
    bool hasFields = [[usernameInput stringValue] length] > 0 && [[passwordInput stringValue] length] > 0;
	[loginButton setEnabled:hasFields];
}

- (void)load
{
	BOOL isLoggedIn = [[puush config] stringForKey:@"username"] != nil;

	[loginScreen setHidden:isLoggedIn];
	[accountInfoScreen setHidden:!isLoggedIn];

	if (isLoggedIn)
	{
		[usernameDisplay setStringValue:[[puush config] stringForKey:@"username"]];
		[keyDisplay setStringValue:[[puush config] stringForKey:@"key"]];
		[typeDisplay setStringValue:[[puush config] stringForKey:@"typestring"]];
		[expiryDisplay setStringValue:[[puush config] stringForKey:@"expiry"]];
		[usageDisplay setStringValue:[[puush config] stringForKey:@"usage"]];
        
        [devCheckbox setHidden:[[puush config] integerForKey:@"type"] != 9];
        [devCheckbox setState:[[puush config] boolForKey:@"dev"]];
	}
	else {
		[usernameInput setStringValue:@""];
		[passwordInput setStringValue:@""];
		[usernameDisplay setStringValue:@""];
		[keyDisplay setStringValue:@""];
		[typeDisplay setStringValue:@""];
		[expiryDisplay setStringValue:@""];
		[usageDisplay setStringValue:@""];
	}

	[self updateButtonEnabledStatus];

	[[puush config] synchronize];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
	[self updateButtonEnabledStatus];
}

- (IBAction) newAccount:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[puushCommon getPuushUrlFor:@"register"]];
}

- (IBAction) forgotPassword:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[puushCommon getPuushUrlFor:@"reset_password"]];
}

-(BOOL) performKeyEquivalent:(NSEvent *)event
{
	if (([event modifierFlags] & NSCommandKeyMask) > 0 && [event keyCode] == kVK_ANSI_W)
	{
		[[preferencesWindow Instance] close];
		return true;
	}

	if ([event keyCode] == kVK_Return)
	{
		[loginButton performClick:self];
		return true;
	}

	return [super performKeyEquivalent:event];
}

- (IBAction) login:(id)sender
{
	if ([puushCommon isLoggedIn]) return;

	[puushCommon loginWithUsername:[usernameInput stringValue] password:[passwordInput stringValue] delegate:self];
}

-(void) loginResult:(int)success
{
	if (success >= 0)
	{
		[puush UpdateHistory];
		[self load];
	}
	else {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Login failed." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check your username/password and try again."];
		[alert runModal];
	}
}

- (void)devToggle:(id)sender
{
    NSButton *button = (NSButton*)sender;
	[[puush config] setBool:button.state forKey:@"dev"];
	[[puush config] synchronize];
}

- (IBAction) logout:(id)sender
{
	[[puush config] removeObjectForKey:@"username"];
	[[puush config] removeObjectForKey:@"key"];
	[[puush config] synchronize];

	[self load];
}

- (IBAction) viewAccount:(id)sender
{
	[[puush Instance] viewAccount:self];
}

@end
