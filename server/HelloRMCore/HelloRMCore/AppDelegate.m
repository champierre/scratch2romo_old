//
//  AppDelegate.m
//  HelloRMCore
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "iConsole.h"

@interface AppDelegate ()

/**
 HTTPサーバーインスタンス
 */
@property (strong, nonatomic) HTTPServer *httpServer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#ifdef DEBUG
    self.window = [[iConsoleWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [iConsole sharedConsole].deviceShakeToShow = YES;
#else
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#endif

    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    self.httpServer = [HTTPServer new];
    self.httpServer.port = 80;
    self.httpServer.documentRoot = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"htdocs"];
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    [self startServer];
    
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
    [self startServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

@end
