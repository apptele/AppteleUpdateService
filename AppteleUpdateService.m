//
//  AppteleUpdateService.m
//  Copyright © 2017 Apptele.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppteleUpdateService.h"

@implementation AppteleUpdateService

/* Change following appid and secret to your application's appid and secret */
#define APPTELE_APPID @"11223344556677889900aabbccddeeff"
#define APPTELE_SECRET @"ffeeddccbbaa00998877665544332211"

-(id) init
{
    self = [super init];
    if(self)
    {
        authorizationNeeded = NO;
        authorizationAttempts = 0;
    }
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void) dealloc
{
    
}

- (void) checkAndUpdate{

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://apptele.com/api/update-info?version=%@&build=%@",version,build];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode]==401)
    {
        authorizationNeeded = YES;
    }
    else if([httpResponse statusCode]==200 && authorizationNeeded)
    {
        authorizationNeeded=NO;
        authorizationAttempts=0;
        retryAfterAuthorization = YES;
    }
    else
    {
        retryAfterAuthorization = NO;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (authorizationNeeded==NO)
    {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSNumber *status = [json valueForKey:@"status"];
        if (status && status.integerValue==1)
        {
            appUrl = [json objectForKey:@"url"];
            NSNumber *isMandatory = [json objectForKey:@"mandatory"];
            if (appUrl && isMandatory)
            {
                if (isMandatory.integerValue==0)
                {
                    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Update Available"
                                                                          message:@"An update of this application is available."
                                                                         delegate:self
                                                                cancelButtonTitle:@"Install"
                                                                otherButtonTitles:@"Later", nil];
                    [updateAlert show];
                }
                else
                {
                    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Update Needed"
                                                                          message:@"This application needs to be updated."
                                                                         delegate:self
                                                                cancelButtonTitle:@"Install"
                                                                otherButtonTitles:@"Later", nil];
                    [updateAlert show];
                }
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)),     dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        });
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (authorizationNeeded)
    {
        if (authorizationAttempts<1) {
            authorizationAttempts++;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://apptele.com/api/app-token"]];
            
            [request setHTTPMethod:@"POST"];
            NSMutableDictionary *appInfoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              APPTELE_APPID, @"appid",
                              APPTELE_SECRET, @"appsecret",
                              nil];
            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:appInfoDict options:0 error:&error];
            [request setHTTPBody:postData];
            NSURLConnection *authConn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        }
    }
    else if (retryAfterAuthorization)
    {
        [self checkAndUpdate];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}
@end
