//
//  AppteleUpdateService.h
//  Copyright © 2017 Apptele.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppteleUpdateService : NSObject<NSURLConnectionDelegate>
{
    BOOL authorizationNeeded;
    BOOL retryAfterAuthorization;
    NSInteger authorizationAttempts;
    NSString *appUrl;
}
+ (id)sharedInstance;
- (void) checkAndUpdate;
@end
