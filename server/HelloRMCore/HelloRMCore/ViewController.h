//
//  ViewController.h
//  HelloRMCore
//

#import <UIKit/UIKit.h>
#import <RMCore/RMCore.h>

@interface ViewController : UIViewController <RMCoreDelegate>

@property (nonatomic, strong) RMCoreRobotRomo3 *Romo3;

// UI
@property (nonatomic, strong) UIView *connectedView;
@property (nonatomic, strong) UILabel *batteryLabel;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *tiltUpButton;
@property (nonatomic, strong) UIButton *tiltDownButton;

@property (nonatomic, strong) UIView *unconnectedView;

- (void)didTouchStopButton:(UIButton *)sender;
//- (void)didTouchTiltDownButton:(UIButton *)sender;
//- (void)didTouchTiltUpButton:(UIButton *)sender;
- (void)up;
- (void)down;
- (void)stop;
- (void)forward;
- (void)backward;
- (void)rightWithAngle: (NSString *) angle;
- (void)leftWithAngle: (NSString *) angle;
- (void)takePhoto;
- (void)turnTorch: (bool) on;
@end
