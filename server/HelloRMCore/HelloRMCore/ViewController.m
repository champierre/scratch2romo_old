//
//  ViewController.m
//  HelloRMCore
//

#import "ViewController.h"
#import "iConsole.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;

- (void)layoutForConnected;
- (void)layoutForUnconnected;

@end

@implementation ViewController

#pragma mark -- View Lifecycle --

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Assume the Robot is not connected
//    [self layoutForUnconnected];
    
    [self layoutForConnected];

    [self setupAVCapture];

    // To receive messages when Robots connect & disconnect, set RMCore's delegate to self
    [RMCore setDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
}

#pragma mark -- RMCoreDelegate Methods --

- (void)robotDidConnect:(RMCoreRobot *)robot
{
    // Currently the only kind of robot is Romo3, so this is just future-proofing
    if ([robot isKindOfClass:[RMCoreRobotRomo3 class]]) {
        self.Romo3 = (RMCoreRobotRomo3 *)robot;
        
        // Change Romo's LED to be solid at 80% power
        [self.Romo3.LEDs setSolidWithBrightness:0.8];
        
        [self layoutForConnected];
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    if (robot == self.Romo3) {
        self.Romo3 = nil;
        
        [self layoutForUnconnected];
    }
}

#pragma mark -- IBAction Methods --

- (void)didTouchStopButton:(UIButton *)sender
{
    // If Romo3 is driving, let's stop driving
    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    if (RomoIsDriving) {
        // Change Romo's LED to be solid at 80% power
        [self.Romo3.LEDs setSolidWithBrightness:0.8];
        
        // Tell Romo3 to stop
        [self.Romo3 stopDriving];
        
        [sender setTitle:@"停止" forState:UIControlStateNormal];
    }
}

#pragma mark -- Private Methods: Build the UI --

- (void)layoutForConnected
{
    // Lets make some buttons so we can tell Romo's base to do stuff
    if (!self.connectedView) {
        self.connectedView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.connectedView.backgroundColor = [UIColor whiteColor];
        
        self.stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.stopButton.frame = CGRectMake(80, 50, 160, 60);
        [self.stopButton setTitle:@"停止" forState:UIControlStateNormal];
        [self.stopButton addTarget:self action:@selector(didTouchStopButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.connectedView addSubview:self.stopButton];
        
        self.ipAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 120, 240, 60)];
        [self.connectedView addSubview:self.ipAddressLabel];

//        self.tiltDownButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        self.tiltDownButton.frame = CGRectMake(80, 130, 80, 60);
//        [self.tiltDownButton setTitle:@"下を向く" forState:UIControlStateNormal];
//        [self.tiltDownButton addTarget:self action:@selector(didTouchTiltDownButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self.connectedView addSubview:self.tiltDownButton];
//        
//        self.tiltUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        self.tiltUpButton.frame = CGRectMake(180, 130, 80, 60);
//        [self.tiltUpButton setTitle:@"上を向く" forState:UIControlStateNormal];
////        [self.tiltUpButton addTarget:self action:@selector(didTouchTiltUpButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//                [self.tiltUpButton addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
//        [self.connectedView addSubview:self.tiltUpButton];
    }
    
    [self.unconnectedView removeFromSuperview];
    [self.view addSubview:self.connectedView];
}

- (void)layoutForUnconnected
{
    // If we aren't connected to a Romo base, just show a label
    if (!self.unconnectedView) {
        self.unconnectedView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.unconnectedView.backgroundColor = [UIColor whiteColor];
        
        UILabel *notConnectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.center.y, self.view.frame.size.width, 40)];
        notConnectedLabel.textAlignment = NSTextAlignmentCenter;
        notConnectedLabel.text = @"Romo とつながっていません";
        [self.unconnectedView addSubview:notConnectedLabel];
    }

    [self.connectedView removeFromSuperview];
    [self.view addSubview:self.unconnectedView];
}

#pragma mark -- Other Methods --

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

- (void)setupAVCapture
{
    NSError *error = nil;
    
    // 入力と出力からキャプチャーセッションを作成
    self.session = [[AVCaptureSession alloc] init];
    
    // 正面に配置されているカメラを取得
//    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = [self frontCamera];
    
    // カメラからの入力を作成し、セッションに追加
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    [self.session addInput:self.videoInput];
    
    // 画像への出力を作成し、セッションに追加
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.session addOutput:self.stillImageOutput];
    
    // セッション開始
    [self.session startRunning];
}

- (void)forward {
    
    // If Romo3 is driving, let's stop driving
    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    if (!RomoIsDriving) {
        [iConsole log:@"forward"];

        // Change Romo's LED to pulse
        [self.Romo3.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
        
        // Romo's top speed is around 0.75 m/s
        float speedInMetersPerSecond = 0.25;
        
        // Give Romo the drive command
        [self.Romo3 driveForwardWithSpeed: speedInMetersPerSecond];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
}

- (void)backward {
    
    // If Romo3 is driving, let's stop driving
    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    if (!RomoIsDriving) {
        [iConsole log:@"backward"];
        
        // Change Romo's LED to pulse
        [self.Romo3.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
        
        // Romo's top speed is around 0.75 m/s
        float speedInMetersPerSecond = 0.25;
        
        // Give Romo the drive command
        [self.Romo3 driveBackwardWithSpeed: speedInMetersPerSecond];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
}

- (void)stop {
    [iConsole log:@"stop"];

    // If Romo3 is driving, let's stop driving
    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    if (RomoIsDriving) {
        // Change Romo's LED to be solid at 80% power
        [self.Romo3.LEDs setSolidWithBrightness:0.8];
        
        // Tell Romo3 to stop
        [self.Romo3 stopDriving];
    }
}

- (void)up
{
    // If Romo3 is tilting, stop tilting
    BOOL RomoIsTilting = (self.Romo3.tiltMotor.powerLevel != 0);
    if (RomoIsTilting) {
        // Tell Romo3 to stop tilting
        [self.Romo3 stopTilting];
    } else {
        // Tilt up by ten degrees
        float tiltByAngleInDegrees = 10.0;
        
        [self.Romo3 tiltByAngle:tiltByAngleInDegrees
                     completion:^(BOOL success) {
                         // Reset button title on the main queue
                     }];
    }
}

- (void)down
{
    // If Romo3 is tilting, stop tilting
    BOOL RomoIsTilting = (self.Romo3.tiltMotor.powerLevel != 0);
    if (RomoIsTilting) {
        
        // Tell Romo3 to stop tilting
        [self.Romo3 stopTilting];

    } else {

        // Tilt down by ten degrees
        float tiltByAngleInDegrees = -10.0;
        
        [self.Romo3 tiltByAngle:tiltByAngleInDegrees
                     completion:^(BOOL success) {
                     }];
    }
}

- (void)rightWithAngle: (NSString *) angle
{
    // If Romo3 is driving, let's stop driving
    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    if (!RomoIsDriving) {
        [iConsole log:@"right"];
        
        float floatAngle = [angle floatValue] * -1;
        float radius = 0;
        
        // Give Romo the drive command
        [self.Romo3 turnByAngle:floatAngle withRadius:radius completion:nil];
    }
}

- (void)leftWithAngle: (NSString *) angle
{
    // If Romo3 is driving, let's stop driving
    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    if (!RomoIsDriving) {
        [iConsole log:@"left"];
        
        float floatAngle = [angle floatValue];
        float radius = 0;
        
        // Give Romo the drive command
        [self.Romo3 turnByAngle:floatAngle withRadius:radius completion:nil];
    }
}

-(void)takePhoto
{
    // ビデオ入力のAVCaptureConnectionを取得
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (videoConnection == nil) {
        return;
    }
    
    // ビデオ入力から画像を非同期で取得。ブロックで定義されている処理が呼び出され、画像データを引数から取得する
    [self.stillImageOutput
     captureStillImageAsynchronouslyFromConnection:videoConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (imageDataSampleBuffer == NULL) {
             return;
         }
         
         // 入力された画像データからJPEGフォーマットとしてデータを取得
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         // JPEGデータからUIImageを作成
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         // アルバムに画像を保存
         UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
     }];

}

-(void)turnTorch: (bool) on
{
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

@end
