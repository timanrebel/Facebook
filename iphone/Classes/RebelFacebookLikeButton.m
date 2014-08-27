/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "RebelFacebookLikeButton.h"

@implementation RebelFacebookLikeButton

-(void)dealloc
{
    RELEASE_TO_NIL(button);
    [super dealloc];
}

-(void)initializeState
{
#if DEBUG
    [FBSettings enableBetaFeature:FBBetaFeaturesLikeButton];
#endif
    
    button = [[FBLikeControl alloc] init];
    button.objectID = @"http://facebook.com/rebelsapp";
    
    [self addSubview:button];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    if (button!=nil)
    {
        [TiUtils setView:button positionRect:bounds];
    }
}


-(void)willMoveToSuperview:(UIView *)newSuperview
{
	NSLog(@"[VIEW LIFECYCLE EVENT] willMoveToSuperview");
}


-(void)setUrl_:(id)url
{
	// This method is a property 'setter' for the 'color' property of the
	// view. View property methods are named using a special, required
	// convention (the underscore suffix).
	
	NSLog(@"[VIEW LIFECYCLE EVENT] Property Set: setUrl_");
    NSLog(@"Like available: %@", FBLikeControl.dialogIsAvailable);
	
//    button.objectID = url;
}

@end
