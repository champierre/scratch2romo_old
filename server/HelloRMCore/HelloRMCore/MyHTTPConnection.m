#import "MyHTTPConnection.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "iConsole.h"

@implementation MyHTTPConnection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    [iConsole log:path];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *segments = [path componentsSeparatedByString:@"/"];
    NSString *action = segments[1];

    NSLog(@"path: %@", path);
    if ([action isEqualToString:@"up"])
    {
        [app.viewController up];
    } else if ([action isEqualToString:@"down"])
    {
        [app.viewController down];
    } else if ([action isEqualToString:@"forward"])
    {
        [app.viewController forward];
    } else if ([action isEqualToString:@"backward"])
    {
        [app.viewController backward];
    } else if ([action isEqualToString:@"right"])
    {
        NSString *angle = segments[2];
        [app.viewController rightWithAngle:angle];
    } else if ([action isEqualToString:@"left"])
    {
        NSString *angle = segments[2];
        [app.viewController leftWithAngle:angle];
    } else if ([action isEqualToString:@"takePhoto"])
    {
        [app.viewController takePhoto];
    } else if ([action isEqualToString:@"turnLightOn"])
    {
        [app.viewController turnTorch:YES];
    } else if ([action isEqualToString:@"turnLightOff"])
    {
        [app.viewController turnTorch:NO];
    }
	return [super httpResponseForMethod:method URI:path];
}

@end
