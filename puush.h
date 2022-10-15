//
//  puush.h
//  puush
//
//  Created by Dean Herbert on 10/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "menuBarItem.h"
#import "BindingManager.h"
#import "Growl.h"
#import <Sparkle/Sparkle.h>
#import "HistoryView.h"
#import "QuickStartController.h"

//#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface puush : NSObject {
//#else
//@interface puush : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
//#endif
    NSWindow *window;
	menuBarItem *statusBar;
	
	NSMenuItem *menuItemDisabled;
	NSView *menuViewTitle;
	NSTextField *menuViewTitleText;
	
	NSMenuItem *menuItemSelectArea;
	NSMenuItem *menuItemDesktopScreenshot;
	NSMenuItem *menuItemUploadFile;
	
	NSMenuItem *menuItemUploadCancel;
	NSMenuItem *menuItemUploadProgress;
	NSMenuItem *menuItemUploadSeparator;
    
    int lastEventId;
	
	HistoryView *historyView;
	
	SUUpdater *updater;
	
	QuickStartController *quickStart;
	
	BOOL isCapturingScreen;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet menuBarItem *statusBar;
@property (retain) IBOutlet NSMenuItem *menuItemDisabled;
@property (retain) IBOutlet NSView *menuViewTitle;
@property (retain) IBOutlet NSTextField *menuViewTitleText;
@property (retain) IBOutlet SUUpdater *updater;
@property (retain) IBOutlet NSMenuItem *menuItemSelectArea;
@property (retain) IBOutlet NSMenuItem *menuItemDesktopScreenshot;
@property (retain) IBOutlet NSMenuItem *menuItemUploadFile;

@property (retain) IBOutlet NSMenuItem *menuItemUploadCancel;
@property (retain) IBOutlet NSMenuItem *menuItemUploadProgress;
@property (retain) IBOutlet NSMenuItem *menuItemUploadSeparator;

@property int lastEventId;

@property (retain) IBOutlet HistoryView *historyView;
@property (retain) QuickStartController *quickStart;
@property BOOL isCapturingScreen;

-(void)setUploadCancellable:(BOOL)cancellable;

- (IBAction) quit:(id)sender;
- (IBAction) toggleDisable:(id)sender;
- (IBAction) displayPreferences:(id)sender;
- (IBAction) viewAccount:(id)sender;

- (IBAction) startInteractiveCapture:(id)sender;
- (IBAction) startDesktopCapture:(id)sender;
- (IBAction) startUploadFileSelection:(id)sender;

- (IBAction) cancelUpload:(id)sender;
-(void)setUploadProgress:(NSNumber*)progress;

- (void)displayDockIconIfRequired;



+ (BOOL) Restart;



+ (void)copyToClipboard:(NSString*)str;
+ (void)growlWith:(NSString*)text;

+ (void) startMonitoringFiles;
+ (void) stopMonitoringFiles;

+ (void) UpdateHistory;

+ (void) handleInvalidAuthentication;

+ (puush*) Instance;
+ (NSUserDefaults*) config;
+ (BindingManager*) bindingManager;

+ (void) startAtStartup:(BOOL)val;

@end
