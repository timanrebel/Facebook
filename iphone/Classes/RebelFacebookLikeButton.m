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

-(void)configurationSet
{
    button = [[FBLikeControl alloc] init];
    
    if([self proxyValueForKey:@"objectID"]) {
        NSString *objectID = [self proxyValueForKey:@"objectID"];
        
        ENSURE_STRING(objectID);
        
        button.objectID = objectID;
    }
    
    if([self proxyValueForKey:@"color"])
        button.foregroundColor = [[TiUtils colorValue:[self proxyValueForKey:@"color"]] _color];
    
    if([self proxyValueForKey:@"style"]) {
        NSString *bType = [self proxyValueForKey:@"style"];
        
        ENSURE_STRING(bType);
        
        if([bType isEqualToString:@"boxCount"])
            button.likeControlStyle = FBLikeControlStyleBoxCount;
        else if([bType isEqualToString:@"button"])
            button.likeControlStyle = FBLikeControlStyleButton;
    }
    
    if([self proxyValueForKey:@"align"]) {
        NSString *align = [self proxyValueForKey:@"align"];
        
        ENSURE_STRING(align);
        
        if([align isEqualToString:@"right"])
            button.likeControlHorizontalAlignment = FBLikeControlHorizontalAlignmentRight;
        else if([align isEqualToString:@"center"])
            button.likeControlHorizontalAlignment = FBLikeControlHorizontalAlignmentCenter;
    }
    
    if([self proxyValueForKey:@"auxiliaryPosition"]) {
        NSString *position = [self proxyValueForKey:@"auxiliaryPosition"];
        
        ENSURE_STRING(position);
        
        if([position isEqualToString:@"top"])
            button.likeControlAuxiliaryPosition = FBLikeControlAuxiliaryPositionTop;
        else if([position isEqualToString:@"bottom"])
            button.likeControlAuxiliaryPosition = FBLikeControlAuxiliaryPositionBottom;
    }
    
    if([self proxyValueForKey:@"soundEnabled"] != nil)
        button.soundEnabled = [self proxyValueForKey:@"soundEnabled"];
    
    [self addSubview:button];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    if (button != nil)
    {
        [TiUtils setView:button positionRect:bounds];
    }
    
    [super frameSizeChanged:frame bounds:bounds];
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
	NSLog(@"[VIEW LIFECYCLE EVENT] willMoveToSuperview");
}

@end
