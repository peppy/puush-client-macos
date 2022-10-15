//
//  Quickstart.h
//
//  Created by Dean Herbert on 10/06/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "puushCommon.h"

@interface QuickStartWindow : NSWindow<LoginDelegate> {
    IBOutlet NSButton *checkStartup;
    IBOutlet NSBox *loginBox;
    IBOutlet NSButton *loginButton;
	IBOutlet NSButton *closeButton;
    IBOutlet NSTextField *passwordInput;
    IBOutlet NSTextField *usernameInput;
    IBOutlet NSView *view;
}

- (IBAction)closeWindow:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)login:(id)sender;

- (void)setStuffUp;
@end
