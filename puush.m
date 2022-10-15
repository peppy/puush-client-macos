//
//  puush.m
//  puush
//
//  Created by Dean Herbert on 10/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "puush.h"
#import "preferencesWindow.h"
#import "FileUpload.h"
#import <Carbon/Carbon.h>
#import "GrowlApplicationBridge.h"
#import <AudioToolbox/AudioServices.h>
#import "QuickStartController.h"
#import "UKLoginItemRegistry.h"
#import "puushCommon.h"	

@implementation puush

@synthesize window;
@synthesize statusBar;
@synthesize menuItemDisabled;
@synthesize menuViewTitle;
@synthesize menuViewTitleText;

@synthesize isCapturingScreen;

@synthesize menuItemSelectArea;
@synthesize menuItemDesktopScreenshot;
@synthesize menuItemUploadFile;

@synthesize menuItemUploadCancel;
@synthesize menuItemUploadProgress;
@synthesize menuItemUploadSeparator;

@synthesize historyView;

@synthesize updater;

BOOL growlAvailable;
BOOL enabled = true;

static NSUserDefaults *_config;
static BindingManager *_bindingManager;

@synthesize quickStart;
@synthesize lastEventId;

+ (NSUserDefaults*) config
{
	return _config;
}

+ (BindingManager*) bindingManager
{
	return _bindingManager;
}

static puush *instance;

+ (puush*) Instance
{
	return instance;
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	instance = self;
	
    [self initializeEventStream];
		
	//Initialize growl...
	NSBundle *myBundle = [NSBundle bundleForClass:[puush class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	growlAvailable = [growlBundle load];
	
	if (growlAvailable)
		[GrowlApplicationBridge setGrowlDelegate:self];
	
	//Initialise configuration management...
	_config = [NSUserDefaults standardUserDefaults];
	
	//load initial config values into vars...
	if ([_config boolForKey:@"disabled"])
		[self toggleDisable:self];
	
	[updater checkForUpdatesInBackground];
		
	[self displayDockIconIfRequired];

	//Initialize key binding management
	_bindingManager = [[BindingManager alloc] init];
	
	//Set version number in menu...
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *versionTitle = [NSString stringWithFormat:@"puush %@",version];
	[menuViewTitleText setStringValue:versionTitle];
	
	[HistoryView updateHistory];
	
	if ([[puush config] integerForKey:@"p"] > 0)
		[[preferencesWindow sharedPrefsWindowController] showWindow:self];
		
	if (![puushCommon isLoggedIn])
	{
		self.quickStart = [[[QuickStartController alloc] initWithWindowNibName:@"QuickStart"] autorelease];
		[quickStart showWindow:self];
		[NSApp activateIgnoringOtherApps:YES];
	}
}

- (void)displayDockIconIfRequired
{
	BOOL iconInDock	= [[puush config] boolForKey:@"DockIcon"];
    if (iconInDock) {
		ProcessSerialNumber psn = { 0, kCurrentProcess };
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
}

+ (void) handleInvalidAuthentication
{
	[puush growlWith:[NSString stringWithFormat:@"Authentication failure.  Your API key may no longer be valid."]];
	
	[[puush config] removeObjectForKey:@"username"];
	[[puush config] removeObjectForKey:@"key"];
	[[puush config] synchronize];
	
	[[self Instance] checkLogin];
}

BOOL checkedLoginOnce;
- (BOOL) checkLogin
{
	if (![puushCommon isLoggedIn])
	{
		if (checkedLoginOnce) return false;
		
		[[preferencesWindow sharedPrefsWindowController] showWindow:self];
		[[preferencesWindow sharedPrefsWindowController] displayViewForIdentifier:@"Account" animate:YES];
		[[[[preferencesWindow sharedPrefsWindowController] window] toolbar] setSelectedItemIdentifier:@"Account"];
		
		checkedLoginOnce = true;
		
		return false;
	}
	
	checkedLoginOnce = false;

	return true;
}

- (IBAction) startDesktopCapture:(id)sender
{
	[puush startMonitoringFiles];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd hh.mm.ss"];
	
	NSString *desktop = [NSString stringWithFormat:@"%@/Desktop/Screenshot %@.png", NSHomeDirectory(), [formatter stringFromDate:[NSDate date]]];
	
	NSTask *task = [[[NSTask alloc] init] autorelease];
	[task setLaunchPath:@"/usr/sbin/screencapture"];
	[task setArguments:[NSArray arrayWithObjects:@"-m",desktop,nil]];

	[task launch];
}

- (IBAction) startInteractiveCapture:(id)sender
{
	[puush startMonitoringFiles];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd hh.mm.ss"];
	
	NSString *desktop = [NSString stringWithFormat:@"%@/Desktop/Screenshot %@.png", NSHomeDirectory(), [formatter stringFromDate:[NSDate date]]];

	NSArray *arr = [NSArray arrayWithObjects:@"-i",desktop,nil];

	NSTask *task = [[[NSTask alloc] init] autorelease];
	[task setLaunchPath:@"/usr/sbin/screencapture"];
	[task setArguments:arr];

	[task launch];
}

- (IBAction) startUploadFileSelection:(id)sender
{
	if (![self checkLogin]) return;
	
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setDirectory:@"~/Desktop/"];
	[openDlg setAllowsMultipleSelection:NO];
	
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton)
	{
		[[FileUpload Instance] uploadFile:[openDlg filename] deleteAfterUpload:false];
	}
}

+(void)copyToClipboard:(NSString*)str
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pb declareTypes:types owner:self];
	[pb setString: str forType:NSStringPboardType];
}

+ (void)growlWith:(NSString*)text
{
	if (growlAvailable && ![[puush config] boolForKey:@"NotificationGrowlDisabled"])
	{
		
		[GrowlApplicationBridge notifyWithTitle:@"puush!"
									description:text
							   notificationName:@"puush"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:text];
	}
}

+ (void) startMonitoringFiles
{
	instance.isCapturingScreen = true;
//	[instance checkForScreenshots];
}

+ (void) stopMonitoringFiles
{
	instance.isCapturingScreen = false;
}


+ (void) UpdateHistory
{
	[HistoryView updateHistory];
}

FSEventStreamRef stream;

- (void) initializeEventStream
{
    NSString *desktop = [NSString stringWithFormat:@"%@/Desktop/",NSHomeDirectory()];
    NSArray *pathsToWatch = [NSArray arrayWithObject:desktop];

    void *appPointer = (void *)self;
    
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 1.0;
    stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (CFArrayRef) pathsToWatch,
                                 lastEventId,
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagUseCFTypes
                                 );
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}

void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    if (!enabled || ![puush Instance].isCapturingScreen) return;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @synchronized([puush Instance])
    {
        size_t i;
        
        int newLast = [puush Instance].lastEventId;
        for(i=0; i < numEvents; i++)
            if (eventIds[i] > newLast)
                newLast = eventIds[i];
        
        NSString *desktop = [NSString stringWithFormat:@"%@/Desktop/",NSHomeDirectory()];

        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:desktop error:nil];
                    
        for (i = 0; i < [files count]; i++)
        {
            NSString *newFilename = [files objectAtIndex:i]; //[(NSArray *)eventPaths objectAtIndex:i];
            
            if ([newFilename rangeOfString:@".png"].location != NSNotFound)
            {
                if ([newFilename rangeOfString:@".png"].location != [newFilename length] - 4)
                    continue;
                
                newFilename = [desktop stringByAppendingString:newFilename];
                
                char textEncoding[256];
                ssize_t attrSize;
                attrSize = getxattr([newFilename fileSystemRepresentation], "com.apple.metadata:kMDItemIsScreenCapture", textEncoding, sizeof(textEncoding), 0, 0);
                
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:newFilename error:NULL];
                NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];

                BOOL attrDate = abs([fileModDate timeIntervalSinceNow]) < 60;
                
                if (attrSize && attrDate)
                {
#if DEBUG
                    NSLog(@"Uploading %@", newFilename);
#endif
                    if (![[FileUpload Instance] uploadFile:newFilename deleteAfterUpload:true])
                        continue;
                    
                    [puush Instance].isCapturingScreen = false;
                    continue;
                }
            }
        }
        
        [puush Instance].lastEventId = newLast;
    }
    
    [pool release];
}

- (void) growlNotificationWasClicked:(id)clickContext
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:(NSString*)clickContext]];
}

- (IBAction) quit:(id)sender;
{
	exit(0);
}

- (IBAction) toggleDisable:(id)sender
{
	enabled = !enabled;
	[menuItemDisabled setState:enabled ? NSOffState : NSOnState];
	[_config setBool:!enabled forKey:@"disabled"];
}

- (IBAction) displayPreferences:(id)sender
{
    if (![puushCommon isLoggedIn] && self.quickStart != nil)
		return;

	[[preferencesWindow sharedPrefsWindowController] showWindow:self];
}

- (IBAction) viewAccount:(id)sender
{
	if (![self checkLogin])
		return;

	NSURL *url = [puushCommon getPuushUrlFor:[NSString stringWithFormat:@"login/go/?k=%@",
					 [[puush config] stringForKey:@"key"]]];
	[[NSWorkspace sharedWorkspace] openURL:url];
}	

-(void) application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	for (NSString *filename in filenames)
		[[FileUpload Instance] uploadFile:filename deleteAfterUpload:false];
}

- (IBAction) cancelUpload:(id)sender
{
	[[FileUpload Instance] cancelUpload];
}

-(void)setUploadCancellable:(BOOL)cancellable
{
	[menuItemUploadCancel setHidden:!cancellable];
	[menuItemUploadProgress setHidden:!cancellable];
	[menuItemUploadSeparator setHidden:!cancellable];
}

-(void)setUploadProgress:(NSNumber*)progress
{
	[menuItemUploadProgress setTitle:[NSString stringWithFormat:@"Uploading... (%.1f%%)",[progress floatValue]]];
}

+ (BOOL) Restart
{
	//$N = argv[N]
	NSString *killArg1AndOpenArg2Script = @"kill -9 $1 \n open \"$2\" --args -p 1";
	
	//NSTask needs its arguments to be strings
	NSString *ourPID = [NSString stringWithFormat:@"%d",
						[[NSProcessInfo processInfo] processIdentifier]];
	
	//this will be the path to the .app bundle,
	//not the executable inside it; exactly what `open` wants
	NSString * pathToUs = [[NSBundle mainBundle] bundlePath];
	
	NSArray *shArgs = [NSArray arrayWithObjects:@"-c", // -c tells sh to execute the next argument, passing it the remaining arguments.
					   killArg1AndOpenArg2Script,
					   @"", //$0 path to script (ignored)
					   ourPID, //$1 in restartScript
					   pathToUs, //$2 in the restartScript
					   nil];
	NSTask *restartTask = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
	[restartTask waitUntilExit]; //wait for killArg1AndOpenArg2Script to finish
	NSLog(@"*** ERROR: %@ should have been terminated, but we are still running", pathToUs);
	assert(!"We should not be running!");
}


+ (void) startAtStartup:(BOOL)val
{
	[[puush config] setBool:val forKey:@"Startup"];
	[[puush config] synchronize];

	if (val) {
		[UKLoginItemRegistry addLoginItemWithPath:[[NSBundle mainBundle] bundlePath] hideIt: NO];
	} else {
		[UKLoginItemRegistry removeLoginItemWithPath:[[NSBundle mainBundle] bundlePath]];
	}
}

@end
