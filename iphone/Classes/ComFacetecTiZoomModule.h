/**
 * ZoomAuthentication
 *
 * Created by Your Name
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "TiApp.h"
@import ZoomAuthentication;

@interface ComFacetecTiZoomModule : TiModule
{
}
@end

@interface ZoomDelegate : NSObject <ZoomEnrollmentDelegate, ZoomAuthenticationDelegate>
{
    KrollCallback* _callback;
}
- (id) initWithCallback:(KrollCallback*)callback;
@end
