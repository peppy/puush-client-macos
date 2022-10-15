//
//  preferencesGeneral.h
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface preferencesGeneral : NSView {
	NSButton *notificationGrowl;
	NSButton *notificationSound;
	NSButton *notificationClipboard;
	NSButton *notificationBrowser;
	
	NSButton *generalIconInDock;
	NSButton *generalStartAtStartup;
	
	NSButton *binding1;
	NSButton *binding2;
	NSButton *binding3;
	
	NSButton *activeBindingButton;
}

@property (retain) IBOutlet NSButton *notificationGrowl;
@property (retain) IBOutlet NSButton *notificationSound;
@property (retain) IBOutlet NSButton *notificationClipboard;
@property (retain) IBOutlet NSButton *notificationBrowser;

@property (retain) IBOutlet NSButton *generalIconInDock;
@property (retain) IBOutlet NSButton *generalStartAtStartup;

@property (retain) IBOutlet NSButton *binding1;
@property (retain) IBOutlet NSButton *binding2;
@property (retain) IBOutlet NSButton *binding3;

@property (retain) NSButton *activeBindingButton;

- (IBAction)toggleGrowl:(id)sender;
- (IBAction)toggleSound:(id)sender;
- (IBAction)toggleClipboard:(id)sender;
- (IBAction)toggleBrowser:(id)sender;

- (IBAction)toggleDockIcon:(id)sender;
- (IBAction)toggleStartAtStartup:(id)sender;

- (IBAction)bindingButtonClicked:(id)sender;
- (IBAction)bindingResetButtonClicked:(id)sender;

- (void)load;

@end
