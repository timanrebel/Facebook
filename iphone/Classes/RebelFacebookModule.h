/**
 * Facebook
 *
 * Created by Timan Rebel
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "FacebookSDK.h"

@protocol TiFacebookStateListener
@required
-(void)login;
-(void)logout;
@end


@interface RebelFacebookModule : TiModule
{
	NSMutableArray *stateListeners;
}

-(void)addListener:(id<TiFacebookStateListener>)listener;
-(void)removeListener:(id<TiFacebookStateListener>)listener;

-(void)authorize:(id)args;
-(void)logout:(id)args;

@end
