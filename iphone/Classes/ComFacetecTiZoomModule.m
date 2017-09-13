/**
 * ZoomAuthentication
 *
 * Created by FaceTec
 * Copyright (c) 2017 FaceTec. All rights reserved.
 */

#import "ComFacetecTiZoomModule.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@import ZoomAuthentication;

@implementation ComFacetecTiZoomModule

#pragma mark Internal

- (id)moduleGUID
{
  return @"dcd1184e-c696-46a8-ae8f-5b9faef2ffa7";
}

- (NSString *)moduleId
{
  return @"com.facetec.ti.zoom";
}

#pragma mark Lifecycle

- (void)startup
{
  [super startup];

  NSLog(@"[DEBUG] %@ loaded", self);
}

#pragma Public APIs

- (NSString *)version
{
  return [[Zoom sdk] version];
}

- (void)initialize:(NSArray *)args
{
  ENSURE_UI_THREAD(initialize, args);

  NSString *appToken = [args objectAtIndex:0];
  __block KrollCallback *callback = (KrollCallback *)[args objectAtIndex:1];

  DebugLog(@"[DEBUG] App token %@", appToken);

  [[Zoom sdk] preload];

  [[Zoom sdk] initializeWithAppToken:appToken
                  enrollmentStrategy:ZoomStrategyZoomOnly
                          completion:^(BOOL validationResult) {
                            if (validationResult) {
                              [self _fireCallback:callback withObject:@{
                                @"successful" : NUMBOOL(YES)
                              }];
                            } else {
                              [self _fireCallback:callback withObject:@{
                                @"successful" : NUMBOOL(NO),
                                @"status" : [self _getSdkStatusString]
                              }];
                            }
                            callback = nil;
                          }];
}

- (void)enroll:(NSArray *)args
{
  NSString *userId = [args objectAtIndex:0];
  NSString *encryptionSecret = [args objectAtIndex:1];
  KrollCallback *callback = [args objectAtIndex:2];

  ZoomEnrollmentViewController *vc = [[Zoom sdk] createEnrollmentVC];
  ZoomDelegate *delegate = [[ZoomDelegate alloc] initWithCallback:callback];

  [vc prepareForEnrollmentWithDelegate:delegate
                                userID:userId
    applicationPerUserEncryptionSecret:encryptionSecret
                                secret:nil];

  [[TiApp app] showModalController:vc animated:false];
}

- (void)authenticate:(NSArray *)args
{
  NSString *userId = [args objectAtIndex:0];
  NSString *encryptionSecret = [args objectAtIndex:1];
  KrollCallback *callback = [args objectAtIndex:2];

  ZoomAuthenticationViewController *vc = [[Zoom sdk] createAuthenticationVC];
  ZoomDelegate *delegate = [[ZoomDelegate alloc] initWithCallback:callback];

  [vc prepareForAuthenticationWithDelegate:delegate
                                    userID:userId
        applicationPerUserEncryptionSecret:encryptionSecret];

  [[TiApp app] showModalController:vc animated:false];
}

- (NSNumber *)sdkStatus
{
  return NUMINTEGER([[Zoom sdk] getStatus]);
}

- (NSString *)getUserEnrollmentStatus:(id)args
{
  NSString *userId = [args objectAtIndex:0];
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

- (NSNumber *)isUserEnrolled:(id)args
{
  NSString *userId = [args objectAtIndex:0];
  ZoomUserEnrollmentStatus status = [[Zoom sdk] getUserEnrollmentStatusWithUserID:userId];

  return NUMBOOL(status == ZoomUserEnrollmentStatusUserEnrolled);
}

#pragma Private APIs

- (void)_fireCallback:(KrollCallback *)callback withObject:(id)obj
{
  if (callback != nil) {
    KrollContext *context = [callback context];
    [[TiApp app] fireEvent:callback
                withObject:obj
                    remove:NO
                   context:(id<TiEvaluator>)context.delegate
                thisObject:nil];
  }
}

- (NSString *)_getSdkStatusString
{
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

- (instancetype)initWithCallback:(KrollCallback *)callback
{
  if (self = [super init]) {
    _callback = callback;
  }
  return self;
}

- (void)onZoomEnrollmentResultWithResult:(ZoomEnrollmentResult *)result
{

  ZoomEnrollmentStatus status = [result status];
  NSDictionary *resultDict = @{
    @"successful" : (status == ZoomEnrollmentStatusUserWasEnrolled ? @YES : @NO),
    @"status" : [self convertZoomEnrollmentStatus:status]
  };

  KrollContext *context = [_callback context];
  [[TiApp app] fireEvent:_callback
              withObject:resultDict
                  remove:NO
                 context:(id<TiEvaluator>)context.delegate
              thisObject:nil];

  _callback = nil;
}

- (void)onZoomAuthenticationResultWithResult:(ZoomAuthenticationResult *)result
{

  ZoomAuthenticationStatus status = [result status];
  NSDictionary *resultDict = @{
    @"successful" : NUMBOOL(status == ZoomAuthenticationStatusUserWasAuthenticated),
    @"status" : [self convertZoomAuthenticationStatus:status]
  };

  KrollContext *context = [_callback context];
  [[TiApp app] fireEvent:_callback withObject:resultDict remove:NO context:(id<TiEvaluator>)context.delegate thisObject:nil];

  _callback = nil;
}

- (NSString *)convertZoomEnrollmentStatus:(ZoomEnrollmentStatus)status
{
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

- (NSString *)convertZoomAuthenticationStatus:(ZoomAuthenticationStatus)status
{
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
  return nil;
}

@end
