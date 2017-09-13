/**
 * ZoomAuthentication
 *
 * Created by FaceTec
 * Copyright (c) 2017 FaceTec. All rights reserved.
 */

#import "TiApp.h"
#import "TiModule.h"
#import <ZoomAuthentication/ZoomAuthentication.h>

@interface ComFacetecTiZoomModule : TiModule

- (NSString *)version;

- (void)initialize:(NSArray *)args;

- (void)enroll:(NSArray *)args;

- (void)authenticate:(NSArray *)args;

- (NSNumber *)sdkStatus;

- (NSNumber *)getUserEnrollmentStatus:( __unused id)args;

- (NSNumber *)isUserEnrolled:( __unused id)args;

@end

@interface ZoomDelegate : NSObject <ZoomEnrollmentDelegate, ZoomAuthenticationDelegate> {
  KrollCallback *_callback;
}

- (id)initWithCallback:(KrollCallback *)callback;

@end
