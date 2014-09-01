/**
  *Facebook
 *
  *Created by Timan Rebel
  *Copyright (c) 2014 Timan Rebel. All rights reserved.
 */

#import "RebelFacebookModule.h"

#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#import "JRSwizzle.h"

bool temporarilySuspended = NO;
KrollCallback *loginCallback;

// Create a category which adds new methods to TiApp
@implementation TiApp (Facebook)

- (void)facebookApplicationDidBecomeActive:(UIApplication *)application
{
    // If you're successful, you should see the following output from titanium
    NSLog(@"[DEBUG] RebelFacebookModule#applicationDidBecomeActive");
    
    // be sure to call the original method
    // note: swizzle will 'swap' implementations, so this is calling the original method,
    // not the current method... so this will not infinitely recurse. promise.
    [self facebookApplicationDidBecomeActive:application];
    
    // Add your custom code here...
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
    
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
}

@end

@implementation RebelFacebookModule

// This is the magic bit... Method Swizzling
// important that this happens in the 'load' method, otherwise the methods
// don't get swizzled early enough to actually hook into app startup.
+ (void)load {
    NSError *error = nil;
    
    [TiApp jr_swizzleMethod:@selector(applicationDidBecomeActive:)
                 withMethod:@selector(facebookApplicationDidBecomeActive:)
                      error:&error];
    if(error)
        NSLog(@"[WARN] Cannot swizzle application:openURL:sourceApplication:annotation: %@", error);
}

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"cabc91e7-a6a5-43f0-88c6-5842914d2550";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"rebel.facebook";
}

#pragma mark Lifecycle

-(void)startup
{
    #if DEBUG
    [FBSettings enableBetaFeature:FBBetaFeaturesLikeButton];
    #endif
        
	// you *must *call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	TiThreadPerformOnMainThread(^{
        [FBSession.activeSession close];
    }, NO);

	// you *must *call the superclass
	[super shutdown:sender];
}

-(void)suspend:(id)sender
{
	NSLog(@"[DEBUG] facebook suspend");
    
    temporarilySuspended = YES; // to avoid crazy logic if user rejects a call or SMS
}

-(void)paused:(id)sender
{
	NSLog(@"[DEBUG] facebook paused");
    
    temporarilySuspended = NO; // Since we are guaranteed full resume logic following this
}

-(void)resumed:(id)note
{
	NSLog(@"[DEBUG] facebook resumed");
    
	if (!temporarilySuspended) {
        NSDictionary *launchOptions = [[TiApp app] launchOptions];
        if (launchOptions != nil)
        {
            NSString *urlString = [launchOptions objectForKey:@"url"];
            NSString *sourceApplication = [launchOptions objectForKey:@"source"];
            
            if (urlString != nil) {
                // Note this handler block should be the exact same as the handler passed to any open calls.
                [FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                    // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                    [self sessionStateChanged:session state:state error:error];
                }];
                
                return [FBAppCall handleOpenURL:[NSURL URLWithString:urlString] sourceApplication:sourceApplication];
            } else {
                return NO;
            }
        }
        
        TiThreadPerformOnMainThread(^{
            if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
                // Start with logged-in state, guaranteed no login UX is fired since logged-in
                // If there's one, just open the session silently, without showing the user the login UI
                NSLog(@"[DEBUG] Cached token found, opening active session.");
                [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                                   allowLoginUI:NO
                                              completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                                  // Handler for session state changes
                                                  // This method will be called EACH time the session state changes,
                                                  // also for intermediate states and NOT just when the session open
                                                  [self sessionStateChanged:session state:state error:error];
                                              }];
            }
        }, YES);
        
        return NO;
    }
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
    RELEASE_TO_NIL(stateListeners);
    RELEASE_TO_NIL(loginCallback);
    
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma mark Auth Internals
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    if (error) {
        NSLog(@"[DEBUG] sessionStateChanged error");
        
        BOOL userCancelled = error.fberrorCategory == FBErrorCategoryUserCancelled;
        [self callLoginCallback:NO cancelled:userCancelled withError:error];
    } else {
        switch (state) {
            case FBSessionStateOpen:
                NSLog(@"[DEBUG] FBSessionStateOpen");
                [self callLoginCallback:YES cancelled:nil withError:nil];
                
                break;
            case FBSessionStateClosed:
            case FBSessionStateClosedLoginFailed:
                NSLog(@"[DEBUG] facebook session closed");
                TiThreadPerformOnMainThread(^{
                    [FBSession.activeSession closeAndClearTokenInformation];
                }, YES);
                
                // Show the user the logged-out UI
                [self fireEvent:@"logout"];
                
                break;
            default:
                break;
        }
    }
}

#pragma Public APIs
-(id)uid
{
	__block NSString  *userID;
    TiThreadPerformOnMainThread(^{
        userID = FBSession.activeSession.accessTokenData.userID;
    }, YES);
    
    return userID;
}

-(BOOL)isLoggedIn
{
    return FBSession.activeSession.state == FBSessionStateOpen;
}

-(BOOL)canShare
{
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
    return [FBDialogs canPresentShareDialogWithParams:params];
}

// Returns the active permissions, not the wanted permissions
-(id)permissions
{
    __block NSArray *perms;
    TiThreadPerformOnMainThread(^{
        perms = FBSession.activeSession.permissions;
    }, YES);
    
    return perms;
}

-(id)accessToken
{
    __block NSString  *token;
    TiThreadPerformOnMainThread(^{
        token = FBSession.activeSession.accessTokenData.accessToken;
    }, YES);
    
    return token;
}

-(id)accessTokenData
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            FBSession.activeSession.accessTokenData.accessToken,@"accessToken",
            FBSession.activeSession.accessTokenData.permissions,@"permissions",
            FBSession.activeSession.accessTokenData.declinedPermissions,@"declinedPermissions",
            FBSession.activeSession.accessTokenData.expirationDate,@"expirationDate",
            FBSession.activeSession.accessTokenData.refreshDate,@"refreshDate",
            FBSession.activeSession.accessTokenData.permissionsRefreshDate,@"permissionsRefreshDate",
            FBSession.activeSession.accessTokenData.appID,@"appID",
            FBSession.activeSession.accessTokenData.userID,@"userID",
            nil];
}

-(id)expirationDate
{
    __block NSDate *expirationDate;
    TiThreadPerformOnMainThread(^{
        expirationDate = FBSession.activeSession.accessTokenData.expirationDate;
    }, YES);
    
    return expirationDate;
}

-(id)audienceNone
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceNone];
}

-(id)audienceOnlyMe
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceOnlyMe];
}

-(id)audienceFriends
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceFriends];
}

-(id)audienceEveryone
{
    return [NSNumber numberWithInt:FBSessionDefaultAudienceEveryone];
}

-(void)authorize:(id)args
{
	NSLog(@"[DEBUG] facebook authorize");
    
    RELEASE_TO_NIL(loginCallback);
    
    NSArray *permissions = [args objectAtIndex:0];
    
    if([args count] > 1)
        loginCallback = [[args objectAtIndex:1] retain];
    
	TiThreadPerformOnMainThread(^{
        // Make sure we do not send nil as permissions
		NSArray *permissions_ = permissions == nil ? [NSArray array] : permissions;
        
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Call login callback
            [self callLoginCallback:YES cancelled:nil withError:nil];
            
        // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            [FBSession openActiveSessionWithReadPermissions:permissions
                                        allowLoginUI:YES
                                        completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                // Call the sessionStateChanged:state:error method to handle session state changes
                [self sessionStateChanged:session state:state error:error];
            }];
        }
	}, NO);
}

-(void)logout:(id)args
{
	NSLog(@"[DEBUG] facebook logout");
    
	if ([self isLoggedIn])
	{
        TiThreadPerformOnMainThread(^{
            [FBSession.activeSession closeAndClearTokenInformation];
        }, NO);
	}
}

// Request publish_actions
-(void)requestNewPublishPermissions:(id)args
{
    ENSURE_ARG_COUNT(args, 3);
    
    NSArray *newPermissions = [args objectAtIndex:0];
    int audience = [args objectAtIndex:1];
    KrollCallback *callback = [args objectAtIndex:2];
    
    TiThreadPerformOnMainThread(^{
    
        [FBSession.activeSession requestNewPublishPermissions:newPermissions
                                            defaultAudience:audience
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                
            NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          nil];

            if (!error) {
                [event setObject:YES forKey:@"success"];
            } else {
                // There was an error, handle it
                // See https://developers.facebook.com/docs/ios/errors/
                [event setObject:error forKey:@"error"];
            }
                                                
            if(callback) {
                KrollEvent *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:event thisObject:self];
                [[callback context] enqueue:invocationEvent];
                [invocationEvent release];
            }
        }];
    }, NO);
}

-(void)requestNewReadPermissions:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    NSArray  *newPermissions = [args objectAtIndex:0];
    KrollCallback  *callback = [args objectAtIndex:1];
    
    TiThreadPerformOnMainThread(^{
        
        [FBSession.activeSession requestNewReadPermissions:newPermissions
                                         completionHandler:^(FBSession *session, NSError *error) {
                                                
            NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          nil];
            
            if (!error) {
                [event setObject:YES forKey:@"success"];
            } else {
                // There was an error, handle it
                // See https://developers.facebook.com/docs/ios/errors/
                [event setObject:error forKey:@"error"];
            }
            
            if(callback) {
                KrollEvent  *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:event thisObject:self];
                [[callback context] enqueue:invocationEvent];
                [invocationEvent release];
            }
        }];
    }, NO);
}

-(void)logEvent:eventName
{
    ENSURE_SINGLE_ARG(eventName, NSString);
    
    [FBAppEvents logEvent:eventName];
}

-(void)logPurchase:args
{
    ENSURE_ARG_COUNT(args, 2);
    
    long amount = [args objectAtIndex:0];
    NSString *currency = [args objectAtIndex:1];
    
    [FBAppEvents logPurchase:amount currency:currency];
}

-(void)shareStatus:args
{
    NSDictionary *params = [args objectAtIndex:0];
    NSString *name = [params objectForKey:@"name"];
    KrollCallback *callback = [params objectForKey:@"callback"];
    
    [FBDialogs presentShareDialogWithLink:nil
        name: name
            handler: ^(FBAppCall *call, NSDictionary *results, NSError *error) {
              
                
            if(callback) {
                NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  nil];
                
                if(error)
                    [event setObject:error forKey:@"error"];
                else
                    [event setObject:YES forKey:@"didComplete"];

                KrollEvent  *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:event thisObject:self];
                [[callback context] enqueue:invocationEvent];
            }
          }];
}

-(void)shareLink:args
{
    NSDictionary *params = [args objectAtIndex:0];
    NSURL *link = [NSURL URLWithString:[params objectForKey:@"url"]];
    NSURL *picture = [NSURL URLWithString:[params objectForKey:@"picture"]];
    NSString *name = [params objectForKey:@"name"];
    NSString *caption = [params objectForKey:@"caption"];
    NSString *description = [params objectForKey:@"description"];
    KrollCallback *callback = [params objectForKey:@"callback"];
    
    [FBDialogs presentShareDialogWithLink:link
        name: name
        caption: caption
        description: description
        picture: picture
        clientState: nil
        handler: ^(FBAppCall *call, NSDictionary *results, NSError *error) {
      
            if(callback) {
                NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              error,@"error",
                                              nil];
                
                if(!error)
                    [event setObject:YES forKey:@"didComplete"];
                
                KrollEvent  *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:event thisObject:self];
                [[callback context] enqueue:invocationEvent];
            }
  }];
}

-(void)shareOpenGraphAction:args
{
    NSDictionary *params = [args objectAtIndex:0];
    
    NSURL *link = [NSURL URLWithString:[params objectForKey:@"url"]];
    NSURL *picture = [NSURL URLWithString:[params objectForKey:@"picture"]];
    NSString *title = [params objectForKey:@"title"];
    NSString *description = [params objectForKey:@"description"];
    
    NSString *actionType = [params objectForKey:@"actionType"];
    NSString *previewPropertyName = [params objectForKey:@"previewPropertyName"];
    
    id<FBGraphObject> ogObject = [FBGraphObject openGraphObjectForPostWithType: actionType
                                            title: title
                                            image: picture
                                              url: link
                                      description: description];
    
    id<FBOpenGraphAction> ogAction = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    [ogAction setObject:ogObject forKey:previewPropertyName];
    
    [FBDialogs presentShareDialogWithOpenGraphAction: ogAction
                                          actionType: actionType
                                 previewPropertyName: previewPropertyName
                                         clientState: nil
                                             handler: ^(FBAppCall *call, NSDictionary *results, NSError *error) {
          if(error) {
              NSLog(@"Error: %@", error.description);
          } else {
              NSLog(@"Success!");
//              NSLog( @"%@", results);
          }
      }];
}

-(void)me:args
{
    ENSURE_ARG_COUNT(args, 1);
    
    KrollCallback  *callback = [args objectAtIndex:0];
    
    TiThreadPerformOnMainThread(^{
        NSLog(@"Fetching me");
        if([FBSession.activeSession isOpen])
        {
            [self makeRequestForUserData:callback];
        }
        else
        {
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [self makeRequestForUserData:callback];
            }];
        }
    }, NO);
}

- (void)makeRequestForUserData:(KrollCallback *)callback
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            if(callback) {
                KrollEvent  *invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:result thisObject:self];
                [[callback context] enqueue:invocationEvent];
            }
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"********************************* *error");
            NSLog(@"error: %@", error);
        }
    }];
}

//-(void)showFriendPicker:args
//{
//    // Initialize the friend picker
//    FBFriendPickerViewController *friendPickerController =
//    [[FBFriendPickerViewController alloc] init];
//    // Set the friend picker title
//    friendPickerController.title = @"Pick Friends";
//    
//    // TODO: Set up the delegate to handle picker callbacks, ex: Done/Cancel button
//    
//    // Load the friend data
//    [friendPickerController loadData];
//    // Show the picker modally
//    [friendPickerController presentModallyFromViewController:[args objectAtIndex:0] animated:YES handler:nil];
////    [[TiApp app] showModalController:friendPickerController animated:YES];
//}

#pragma mark Listener work

-(void)callLoginCallback:(id)success cancelled:(BOOL)cancelled withError:(NSError *)error
{
	NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  NUMBOOL(success),@"success",
                                  NUMBOOL(cancelled),@"cancelled",
                                  nil];
	if(error){
        NSString *alertText;
        NSString *alertTitle;
        
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        
        NSDictionary *error = [NSDictionary dictionaryWithObjectsAndKeys:
                                      NUMINT([error code]),@"code",
                                      alertTitle,@"title",
                                      alertText,@"message",
                               nil];
        
        [event setObject:NO forKey:@"success"];
        [event setObject:error forKey:@"error"];
	}
    
    if(success) {
        [event setObject:[self accessTokenData] forKey:@"accessTokenData"];
    }
    
	if(loginCallback) {
        KrollEvent  *invocationEvent = [[KrollEvent alloc] initWithCallback:loginCallback eventObject:event thisObject:self];
        [[loginCallback context] enqueue:invocationEvent];
        [invocationEvent release];
    }
    
    [self fireEvent:@"login" withObject:event];
}


#pragma mark Listeners

-(void)addListener:(id<TiFacebookStateListener>)listener
{
	if (stateListeners==nil)
	{
		stateListeners = [[NSMutableArray alloc]init];
	}
	[stateListeners addObject:listener];
}

-(void)removeListener:(id<TiFacebookStateListener>)listener
{
	if (stateListeners!=nil)
	{
		[stateListeners removeObject:listener];
		if ([stateListeners count]==0)
		{
			RELEASE_TO_NIL(stateListeners);
		}
	}
}


@end
