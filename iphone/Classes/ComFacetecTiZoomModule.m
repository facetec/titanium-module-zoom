/**
 * ZoomAuthentication
 *
 * Created by Your Name
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import "ComFacetecTiZoomModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@import ZoomAuthentication;

@implementation ComFacetecTiZoomModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"dcd1184e-c696-46a8-ae8f-5b9faef2ffa7";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.facetec.ti.zoom";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
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

#pragma Public APIs


-(id)version {
    return [[Zoom sdk] version];
}

-(void)initialize:(id)args
{
    ENSURE_UI_THREAD(initialize, args);
    
    NSString* appToken = [args objectAtIndex:0];
    NSLog(@"[INFO] App token %@", appToken);
    __block KrollCallback* callback = [[args objectAtIndex:1] retain];
    
    [[Zoom sdk] preload];
    
    [[Zoom sdk] initializeWithAppToken:appToken enrollmentStrategy:ZoomStrategyZoomOnly completion:^ void (BOOL validationResult) {
        if (validationResult) {
            [self _fireCallback:callback withObject:@{@"successful": @YES}];
        }
        else {
            NSString* statusStr = [self _getSdkStatusString];
            [self _fireCallback:callback withObject:@{@"successful": @NO, @"status": statusStr}];
        }
        RELEASE_TO_NIL(callback);
    }];
}

-(void)enroll:(id)args
{
    NSString* userId = [args objectAtIndex:0];
    NSString* encryptionSecret = [args objectAtIndex:1];
    KrollCallback* callback = [args objectAtIndex:2];
    
    ZoomEnrollmentViewController *vc = [[Zoom sdk] createEnrollmentVC];
    ZoomDelegate* delegate = [[ZoomDelegate alloc] initWithCallback:callback];
    [vc prepareForEnrollmentWithDelegate:delegate userID:userId applicationPerUserEncryptionSecret:encryptionSecret secret:nil];
    
    [[TiApp app] showModalController:vc animated:false];
}

-(void)authenticate:(id)args
{
    NSString* userId = [args objectAtIndex:0];
    NSString* encryptionSecret = [args objectAtIndex:1];
    KrollCallback* callback = [args objectAtIndex:2];
    
    ZoomAuthenticationViewController *vc = [[Zoom sdk] createAuthenticationVC];
    ZoomDelegate* delegate = [[ZoomDelegate alloc] initWithCallback:callback];
    [vc prepareForAuthenticationWithDelegate:delegate userID:userId applicationPerUserEncryptionSecret:encryptionSecret];
    
    [[TiApp app] showModalController:vc animated:false];
}

-(id)sdkStatus {
    return [[Zoom sdk] getStatus];
}

-(id)getUserEnrollmentStatus:(id)args {
    NSString * userId = [args objectAtIndex:0];
    ZoomUserEnrollmentStatus status = [[Zoom sdk] getUserEnrollmentStatusWithUserID:userId];
    switch (status) {
        case ZoomUserEnrollmentStatusUserEnrolled:
            return @"Enrolled";
        case ZoomUserEnrollmentStatusUserNotEnrolled:
            return @"NotEnrolled";
        case ZoomUserEnrollmentStatusUserInvalidated:
            return @"Invalidated";
    }
}

-(id)isUserEnrolled:(id)args {
    NSString * userId = [args objectAtIndex:0];
    ZoomUserEnrollmentStatus status =  [[Zoom sdk] getUserEnrollmentStatusWithUserID:userId];
    return status == ZoomUserEnrollmentStatusUserEnrolled;
}

- (void) _fireCallback:(KrollCallback*)callback withObject:(id)obj {
    if (callback != nil) {
        KrollContext* context = [callback context];
        [[TiApp app] fireEvent:callback withObject:obj remove:NO context:(id<TiEvaluator>)context.delegate thisObject:nil];
    }
}

- (NSString*)_getSdkStatusString {
    switch ([[Zoom sdk] getStatus]) {
        case ZoomSDKStatusNeverInitialized:
            return @"NeverInitialized";
        case ZoomSDKStatusInitialized:
            return @"Initialized";
        case ZoomSDKStatusNetworkIssues:
            return @"NetworkIssues";
        case ZoomSDKStatusInvalidToken:
            return @"InvalidToken";
        case ZoomSDKStatusDeviceInsecure:
            return @"DeviceInsecure";
        case ZoomSDKStatusVersionDeprecated:
            return @"VersionDeprecated";
    }
    return nil;
}

@end

@implementation ZoomDelegate
- (instancetype)initWithCallback:(KrollCallback*)callback {
    if (self = [super init]) {
        _callback = callback;
        [_callback retain];
    }
    return self;
}

- (void) onZoomEnrollmentResultWithResult:(ZoomEnrollmentResult *)result {


    ZoomEnrollmentStatus status = [result status];
    NSDictionary* resultDict = @{
                                 @"successful": (status == ZoomEnrollmentStatusUserWasEnrolled ? @YES : @NO),
                                 @"status": [self convertZoomEnrollmentStatus: status]
                                 };
    
    KrollContext* context = [_callback context];
    [[TiApp app] fireEvent:_callback withObject:resultDict remove:NO context:(id<TiEvaluator>)context.delegate thisObject:nil];
    
    RELEASE_TO_NIL(_callback)
}

- (void) onZoomAuthenticationResultWithResult:(ZoomAuthenticationResult *)result {
    
    ZoomAuthenticationStatus status = [result status];
    NSDictionary* resultDict = @{
                                 @"successful": (status == ZoomAuthenticationStatusUserWasAuthenticated ? @YES : @NO),
                                 @"status": [self convertZoomAuthenticationStatus: status]
                                 };
    
    KrollContext* context = [_callback context];
    [[TiApp app] fireEvent:_callback withObject:resultDict remove:NO context:(id<TiEvaluator>)context.delegate thisObject:nil];
    
    RELEASE_TO_NIL(_callback)
}

- (NSString*)convertZoomEnrollmentStatus:(ZoomEnrollmentStatus)status {
    // Note: These string values should match exactly with the Android implementation
    switch (status) {
        case ZoomEnrollmentStatusUserWasEnrolled:
            return @"Enrolled";
        case ZoomEnrollmentStatusUserNotEnrolled:
            return @"NotEnrolled";
        case ZoomEnrollmentStatusFailedBecauseOfTimeout:
            return @"Timeout";
        case ZoomEnrollmentStatusFailedBecauseOfLowMemory:
            return @"LowMemory";
        case ZoomEnrollmentStatusFailedBecauseUserCancelled:
            return @"UserCancelled";
        case ZoomEnrollmentStatusFailedBecauseAppTokenNotValid:
            return @"AppTokenNotValid";
        case ZoomEnrollmentStatusFailedBecauseOfOSContextSwitch:
            return @"OSContextSwitch";
        case ZoomEnrollmentStatusFailedBecauseOfDiskWriteError:
            return @"DiskWriteError";
        case ZoomEnrollmentStatusFailedBecauseWifiNotOnInDevMode:
            return @"WifiNotOnInDevMode";
        case ZoomEnrollmentStatusFailedBecauseFingerprintDisabled:
            return @"FingerprintDisabled";
        case ZoomEnrollmentStatusFailedBecauseNoConnectionInDevMode:
            return @"NoConnectionInDevMode";
        case ZoomEnrollmentStatusFailedBecauseCameraPermissionDeniedByUser:
        case ZoomEnrollmentStatusFailedBecauseCameraPermissionDeniedByAdministrator:
            return @"CameraPermissionsDenied";
        case ZoomEnrollmentStatusUserFailedToProvideGoodEnrollment:
        default:
            return @"NotEnrolled";
    }
}

- (NSString*)convertZoomAuthenticationStatus:(ZoomAuthenticationStatus)status {
    // Note: These string values should match exactly with the Android implementation
    switch (status) {
        case ZoomAuthenticationStatusUserWasAuthenticated:
            return @"Authenticated";
        case ZoomAuthenticationStatusFailedBecauseOfTimeout:
            return @"Timeout";
        case ZoomAuthenticationStatusFailedBecauseOfLowMemory:
            return @"LowMemory";
        case ZoomAuthenticationStatusFailedBecauseUserCancelled:
            return @"UserCancelled";
        case ZoomAuthenticationStatusFailedBecauseUserMustEnroll:
            return @"UserMustEnroll";
        case ZoomAuthenticationStatusFailedBecauseAppTokenNotValid:
            return @"AppTokenNotValid";
        case ZoomAuthenticationStatusFailedBecauseOfOSContextSwitch:
            return @"OSContextSwitch";
        case ZoomAuthenticationStatusFailedBecauseTouchIDUnavailable:
            return @"TouchIDUnavailable";
        case ZoomAuthenticationStatusFailedBecauseWifiNotOnInDevMode:
            return @"WifiNotOnInDevMode";
        case ZoomAuthenticationStatusFailedBecauseNoConnectionInDevMode:
            return @"NoConnectionInDevMode";
        case ZoomAuthenticationStatusFailedBecauseCameraPermissionDenied:
            return @"CameraPermissionDenied";
        case ZoomAuthenticationStatusFailedBecauseTouchIDSettingsChanged:
            return @"TouchIDSettingsChanged";
        case ZoomAuthenticationStatusFailedBecauseUserFailedAuthentication:
            return @"FailedAuthentication";
        case ZoomAuthenticationStatusFailedToAuthenticateTooManyTimesAndUserWasDeleted:
            return @"FailedAndWasDeleted";
    }
    return (NSString*)nil;
}
@end


