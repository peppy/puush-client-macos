//
//  puushCommon.h
//  puush
//
//  Created by Dean Herbert on 10/07/09.
//  Copyright 2010 haxors. All rights reserved.
//

@protocol RegistrationDelegate <NSObject>
@optional
- (void)registrationResult:(int)success;
@end

@protocol LoginDelegate <NSObject>
@optional
- (void)loginResult:(int)success;
@end

@interface puushCommon : NSObject {
}

+ (void) cancelNetworkRequests;

+ (void) registerWithUsername:(NSString*)username password:(NSString*)password delegate:(id)delegate;

+ (BOOL) isLoggedIn;

+ (void) logout;

+ (void) loginWithKnownDetailsDelegate:(id<LoginDelegate>)delegate;
+ (void) loginWithUsername:(NSString*)username password:(NSString*)password delegate:(id<LoginDelegate>)delegate;

+ (BOOL) isPro;

+ (NSURL*)getApiUrlFor:(NSString*)action;
+ (NSURL*)getPuushUrlFor:(NSString*)action;

@end
