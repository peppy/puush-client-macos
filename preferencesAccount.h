//
//  preferencesAccount.h
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "puushCommon.h"


@interface preferencesAccount : NSView<LoginDelegate>{
	NSTextField *usernameInput;
	NSTextField *passwordInput;

	NSView *loginScreen;
	NSView *accountInfoScreen;
	NSTextField *usernameDisplay;
	NSTextField *keyDisplay;
	NSTextField *typeDisplay;
	NSTextField *expiryDisplay;
	NSTextField *usageDisplay;

	NSButton *devCheckbox;

	NSButton *loginButton;
}

@property (retain) IBOutlet NSTextField *usernameInput;
@property (retain) IBOutlet NSTextField *passwordInput;

@property (retain) IBOutlet NSView *loginScreen;
@property (retain) IBOutlet NSView *accountInfoScreen;

@property (retain) IBOutlet NSTextField *usernameDisplay;
@property (retain) IBOutlet NSTextField *keyDisplay;
@property (retain) IBOutlet NSTextField *typeDisplay;
@property (retain) IBOutlet NSTextField *expiryDisplay;
@property (retain) IBOutlet NSTextField *usageDisplay;

@property (retain) IBOutlet NSButton *devCheckbox;

@property (retain) IBOutlet NSButton *loginButton;

- (IBAction) login:(id)sender;
- (IBAction) logout:(id)sender;

- (IBAction) devToggle:(id)sender;

- (IBAction) newAccount:(id)sender;
- (IBAction) forgotPassword:(id)sender;

- (IBAction) viewAccount:(id)sender;

@end
