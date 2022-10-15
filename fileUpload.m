//
//  fileUpload.m
//  puush
//
//  Created by Dean Herbert on 10/05/24.
//  Copyright 2010 haxors. All rights reserved.
//

#import "FileUpload.h"
#import "ASIFormDataRequest.h"
#import "puush.h"
#import "puushCommon.h"
#import "SoundEffect.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FileUpload

NSString* getMD5FromFile(NSString *pathToFile) {
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	
    NSData *inputData = [[NSData alloc] initWithContentsOfFile:pathToFile];
    CC_MD5([inputData bytes], [inputData length], outputData);
    [inputData release];
	
    NSMutableString *hash = [[NSMutableString alloc] init];
	
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", outputData[i]];
    }
	
    return hash;
}

@synthesize currentUpload;

NSMutableArray *requests;

#define RETRIES_ALLOWED 5
int retryCount = RETRIES_ALLOWED - 1;

-(id) init
{
	id me = [super init];
	requests = [[[NSMutableArray alloc] init] retain];
	return me;
}

static FileUpload *instance;
+ (FileUpload*) Instance
{
	if (instance == nil)
		instance = [[[FileUpload alloc] init] retain];
	return instance;
}

-(void)startUpload
{
	[self.currentUpload startAsynchronous];
}

- (void)cancelUpload
{
	if (self.currentUpload == nil) return;
	
	retryCount = 0;
	
	[[self currentUpload] cancel];
}

- (void) processQueue
{
	@synchronized(self)
	{
		if (self.currentUpload != nil && ([self.currentUpload error] != nil || self.currentUpload.complete))
		{
			self.currentUpload = nil;
		}

		if (self.currentUpload == nil && [requests count] > 0)
		{
			retryCount = RETRIES_ALLOWED - 1;
			
			self.currentUpload = [requests objectAtIndex:0];
			[requests removeObjectAtIndex:0];
			
			[self performSelectorInBackground:@selector(startUpload) withObject:nil];
		}
		
		[[puush Instance] setUploadCancellable:self.currentUpload != nil];
	}
}

- (BOOL)uploadFile:(NSString*)filename deleteAfterUpload:(BOOL)deleteAfterUpload
{
    @synchronized(self)
    {
        if (![puushCommon isLoggedIn]) return false;
        
        if (currentUpload != nil && [currentUpload.filename compare:filename] == NSOrderedSame)
            return false;
        
        for (int i = 0; i < [requests count]; i++)
            if ([((ASIFormDataRequest*)[requests objectAtIndex:i]).filename compare:filename] == NSOrderedSame)
                return false;
        
        retryCount = RETRIES_ALLOWED - 1;
        
        ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[puushCommon getApiUrlFor:@"up"]] autorelease];
        [request setPostValue:[[puush config] stringForKey:@"key"] forKey:@"k"];
        
        [request setPostValue:@"poop" forKey:@"z"];
        [request setTimeOutSeconds:10];
        [request setPostValue:getMD5FromFile(filename) forKey:@"c"];
        [request setFile:filename forKey:@"f"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestFinished:)];
        [request setDidFailSelector:@selector(requestFailed:)];
        request.deleteAfterSuccess = deleteAfterUpload;

        [requests addObject:request];
        
        [self processQueue];
    }
	
	return true;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Use when fetching text data
	NSArray *split = [[request responseString] componentsSeparatedByString:@","];
	
	int status = [((NSString*)[split objectAtIndex:0]) intValue];
	
	NSString *errorDescription;
	BOOL shouldRetry = false;
	
	//make sure the string is also correct
	if (status == 0 && [[split objectAtIndex:1] rangeOfString:@"puu.sh"].length == 0)
		status = -2;

	if (status < 0)
	{
		switch (status)
		{
			case -1:
				errorDescription = @"Authentication failure";
				[puush handleInvalidAuthentication];
				break;
			case -2:
			default:
				errorDescription = @"Unknown error";
				shouldRetry = true;
				break;
			case -3:
				errorDescription = @"Checksum error";
				shouldRetry = true;
				break;
			case -4:
				errorDescription = @"Insufficient account storage remaining. Please delete some files or consider upgrading to a pro account!";
				shouldRetry = false;
				break;
		}
		
		if (retryCount == 0)
			[puush growlWith:[NSString stringWithFormat:@"puush failed with error: %@",errorDescription]];
		
		if (shouldRetry)
		{
			[self requestFailed:request];
			[pool release];
			return;
		}
	}
    
    long usage = [[split objectAtIndex:2] intValue];
	NSString *usageString = [[NSUserDefaults standardUserDefaults] integerForKey:@"type"] == 0 ? [NSString stringWithFormat:@"%d/200mb",usage/1048576] : [NSString stringWithFormat:@"%dmb",usage/1048576];
	[[NSUserDefaults standardUserDefaults] setObject:usageString forKey:@"usage"];
	
	NSString *url = [split objectAtIndex:1];
	
	if (![[puush config] boolForKey:@"NotificationClipboardDisabled"])
		[puush copyToClipboard:url];
	
	if (request.deleteAfterSuccess)
		[[NSFileManager defaultManager] removeItemAtPath:[request filename] error:nil];

	[puush growlWith:url];

	if ([[puush config] boolForKey:@"NotificationBrowser"])
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
	
	if (![[puush config] boolForKey:@"NotificationSoundDisabled"])
	{
		SoundEffect *soundEffect = [[[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"success2" ofType:@"aif"]] autorelease];
		[soundEffect play];
	}
	
	[puush UpdateHistory];
	
	[self processQueue];
	
	[pool release];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    @synchronized(self)
    {
        SoundEffect *soundEffect = [[[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"error2" ofType:@"aif"]] autorelease];
        [soundEffect play];

        [self processQueue];
        
        if (retryCount-- > 0)
        {
            int retry = retryCount;
            [self uploadFile:[request filename] deleteAfterUpload:request.deleteAfterSuccess];
            retryCount = retry;
        }

        [self processQueue];
    }
}

@end
