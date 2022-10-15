//
//  Quickstart.m
//
//  Created by Dean Herbert on 10/06/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QuickStartWindow.h"
#import "ASIFormDataRequest.h"
#import "puushCommon.h"

@implementation QuickStartWindow

- (void)setStuffUp
{
	[closeButton setEnabled:[puushCommon isLoggedIn]];   
	[self updateButtonEnabledStatus];
}

- (IBAction)closeWindow:(id)sender {
	
	[puush startAtStartup:[checkStartup state]];
	[[puush Instance] setQuickStart:nil];
	
	[self close];
}

- (IBAction)createAccount:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[puushCommon getPuushUrlFor:@"register"]];
}

- (IBAction)forgotPassword:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[puushCommon getPuushUrlFor:@"reset_password"]];
}

-(void) updateButtonEnabledStatus
{
    bool hasFields = [[usernameInput stringValue] length] > 0 && [[passwordInput stringValue] length] > 0;
	[loginButton setEnabled:hasFields];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
	[self updateButtonEnabledStatus];
}

-(BOOL) performKeyEquivalent:(NSEvent *)event
{
	if (([event modifierFlags] & NSCommandKeyMask) > 0 && [event keyCode] == kVK_ANSI_W)
	{
		[self closeWindow:self];
		return true;
	}
	
	if ([event keyCode] == kVK_Return)
	{
		[loginButton performClick:self];
		return true;
	}
	
	return [super performKeyEquivalent:event];
}

- (IBAction)login:(id)sender {
	if ([puushCommon isLoggedIn]) return;
	
	if ([puushCommon isLoggedIn]) return;
	
	[puushCommon loginWithUsername:[usernameInput stringValue] password:[passwordInput stringValue] delegate:self];
}

-(void) loginResult:(int)success
{
	if (success >= 0)
	{
		[loginBox setHidden:true];
		[closeButton setEnabled:true];
	}
	else {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Login failed." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check your username/password and try again."];
		[alert runModal];
	}
}

@end
