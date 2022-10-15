//
//  puushCommon.m
//  puush
//
//  Created by Dean Herbert on 10/07/09.
//  Copyright 2010 haxors. All rights reserved.
//

#import "puushCommon.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation puushCommon

static ASIHTTPRequest *request;

+ (void) cancelNetworkRequests
{
	if (request != nil)
	{
		[request cancel];
		request = nil;
	}
}

#pragma mark ---Registration Functionality---

id<RegistrationDelegate> registrationDelegate;

+(void)registrationResponseFail:(ASIHTTPRequest *)request
{
	[registrationDelegate registrationResult:-3];
}

+(void)registrationResponseSuccess:(ASIHTTPRequest *)request
{
	int responseCode = -3;
	
	NSArray *split = [[request responseString] componentsSeparatedByString:@","];
	
	//-1: missing field
	//-2: email in use
	//-3: unknown
	
	if ([[request responseString] length] > 0)
		responseCode = [[split objectAtIndex:0] intValue];
	
	[registrationDelegate registrationResult:responseCode];
}	

+ (void) registerWithUsername:(NSString*)username password:(NSString*)password delegate:(id)delegate
{
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	registrationDelegate = delegate;
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[puushCommon getApiUrlFor:@"register"]];
	[request setPostValue:username forKey:@"e"];
	[request setPostValue:password forKey:@"p"];
	[request setTimeOutSeconds:30];
	[request setPostValue:@"poop" forKey:@"z"];
	[request setDelegate:self];
	[request setDidFailSelector:@selector(registrationResponseFail:)];
	[request setDidFinishSelector:@selector(registrationResponseSuccess:)];
	[request startAsynchronous];
}

#pragma mark ---Login Functionality---

+ (BOOL) isLoggedIn
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"key"] != nil;
}

+ (void) logout
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"key"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

id<LoginDelegate> loginDelegate;

+(void)loginResponseFail:(ASIHTTPRequest *)request
{
	[loginDelegate loginResult:-1];
}

+(void)loginResponseSuccess:(ASIHTTPRequest *)request
{
	NSArray *split = [[request responseString] componentsSeparatedByString:@","];
	
	int userType = [[split objectAtIndex:0] intValue];
	
	BOOL success = userType >= 0;
	
	if (success)
	{
		NSString *type;
		
		int accountTypeId = [[split objectAtIndex:0] intValue];
		switch (accountTypeId)
		{
			default:
			case 0:
				type = @"Free Account";
				break;
			case 1:
				type = @"Pro Account";
				break;
			case 2:
				type = @"Pro Tester";
				break;
			case 9:
				type = @"Haxor!";
				break;
		}
		
		NSString *expiry = [split objectAtIndex:2];
		if ([expiry length] == 0)
			expiry = @"Never";
			
		long usage = [[split objectAtIndex:3] intValue];
		
		NSString *usageString = accountTypeId == 0 ? [NSString stringWithFormat:@"%d/200mb",(int)(usage/1048576)] : [NSString stringWithFormat:@"%dmb",(int)(usage/1048576)];
		
		[[NSUserDefaults standardUserDefaults] setObject:[split objectAtIndex:1] forKey:@"key"];
		[[NSUserDefaults standardUserDefaults] setObject:type forKey:@"typestring"];
		[[NSUserDefaults standardUserDefaults] setInteger:accountTypeId forKey:@"type"];
		[[NSUserDefaults standardUserDefaults] setObject:expiry forKey:@"expiry"];
		[[NSUserDefaults standardUserDefaults] setObject:usageString forKey:@"usage"];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	[loginDelegate loginResult:userType];
}

+ (BOOL) isPro
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"type"] > 0;
}

+ (void) loginWithKnownDetailsDelegate:(id<LoginDelegate>)delegate
{
	loginDelegate = delegate;
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[puushCommon getApiUrlFor:@"auth"]];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] forKey:@"e"];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"key"] forKey:@"k"];
	[request setTimeOutSeconds:30];
	[request setPostValue:@"poop" forKey:@"z"];
	[request setDelegate:self];
	[request setDidFailSelector:@selector(loginResponseFail:)];
	[request setDidFinishSelector:@selector(loginResponseSuccess:)];
	[request startAsynchronous];
}

+ (void) loginWithUsername:(NSString*)username password:(NSString*)password delegate:(id<LoginDelegate>)delegate
{
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	loginDelegate = delegate;
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[puushCommon getApiUrlFor:@"auth"]];
	[request setPostValue:username forKey:@"e"];
	[request setPostValue:password forKey:@"p"];
	[request setTimeOutSeconds:30];
	[request setPostValue:@"poop" forKey:@"z"];
	[request setDelegate:self];
	[request setDidFailSelector:@selector(loginResponseFail:)];
	[request setDidFinishSelector:@selector(loginResponseSuccess:)];
	[request startAsynchronous];
}

#pragma mark ---API Handling---

+ (NSURL*)getApiUrlFor:(NSString*)action
{
	return [puushCommon getPuushUrlFor:[NSString stringWithFormat:@"api/%@",action]];
}

+ (NSURL*)getPuushUrlFor:(NSString*)action
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://puush.me/%@",action]];
}

@end
