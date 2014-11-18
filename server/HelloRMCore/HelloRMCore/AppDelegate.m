//
//  AppDelegate.m
//  HelloRMCore
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface AppDelegate ()

/**
 HTTPサーバーインスタンス
 */
@property (strong, nonatomic) HTTPServer *httpServer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    self.httpServer = [HTTPServer new];
    self.httpServer.port = 80;
    self.httpServer.documentRoot = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"htdocs"];
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    [self startServer];
    [self getIPAddress];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self stopServer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self getIPAddress];
    [self startServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}


#pragma mark - Private methods
/**
 HTTPサーバーを起動する
 */

- (void)startServer
{
    NSError *error;
    
    if (![self.httpServer start:&error]) {
        NSLog(@"Error starting HTTP Server: %@", error);
    } else {
        NSLog(@"startServer");
    }
}

/**
 HTTPサーバーを停止する
 */
- (void)stopServer
{
    NSLog(@"stopServer");
    [self.httpServer stop];
}

- (void)getIPAddress
{
    NSLog(@"getIPAddress");
    NSString *address = @"N/A";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    self.viewController.ipAddressLabel.text = [NSString stringWithFormat:@"wifi address: %@", address];
}

@end
