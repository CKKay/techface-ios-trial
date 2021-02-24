//
//  CaptureViewController.m
//  Tech Face
//
//  Created by MedEXO on 13/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "CaptureViewController.h"
#import "ConnectDeviceViewController.h"
#import "SaveTreatmentViewController.h"
#import "Server.h"
#import "NSString+Extended.h"
#import "UIImage+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <CoreBluetooth/CoreBluetooth.h>

@import AssetsLibrary;

@interface CaptureViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UIButton *saveandnext;
@property (weak, nonatomic) IBOutlet UIButton *retakephoto;
@property (weak, nonatomic) IBOutlet UIView *videocapture;
@property (weak, nonatomic) IBOutlet UIButton *recordVideoButton;
@property (weak, nonatomic) IBOutlet UIView *Photoapprove;
@property (weak, nonatomic) IBOutlet UIView *Videoapprove;
@property (weak, nonatomic) IBOutlet UIButton *Approvephotobutton;
@property (weak, nonatomic) IBOutlet UIButton *Retakephotobutton;
@property (weak, nonatomic) IBOutlet UIImageView *Photoapproveimage;
@property (weak, nonatomic) IBOutlet UIButton *Approvevideo_button;
@property (weak, nonatomic) IBOutlet UIButton *Retakevideo_video;
@property (weak, nonatomic) IBOutlet UIButton *Playpause_button;
@property (weak, nonatomic) IBOutlet UIImageView *Approve_Videothumbnail;
@property (weak, nonatomic) IBOutlet UILabel *Photocap_conform_text;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@property (nonatomic, strong) NSString *receivedMessage;
@property (nonatomic, assign) int currentMessage;
@property (nonatomic, assign) BOOL isSaving;

@end

@implementation CaptureViewController

- (void)viewDidLoad {
	[super viewDidLoad];

    self.currentMessage = -1;
    self.receivedMessage = @"";
	self.connectView.hidden = false;
	self.finderView.hidden = true;
}

- (void)didReceiveMemoryWarning {
          NSLog(@"Capture Agreement dealloc Warning");

	// Dispose of any resources that can be recreated.
       if ([self isViewLoaded] && [self.view window] == nil) {
           /*
            self.centralManager = nil;
            self.peripheral=nil;
            self.characteristic=nil;
            self.receivedMessage=nil;
            self.view = nil;*/
    
      }
    [super didReceiveMemoryWarning];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙可用");
        [central scanForPeripheralsWithServices:nil options:nil];
    } else {
        //蓝牙连接
        
        [self showDismissAlertWithTitle:@"Message" message:[NSString stringWithFormat:@"Techface 要求藍牙連接權限! 請打開 setting->Tech Face->藍牙"]];
        
    }
    if(central.state==CBManagerStateUnsupported) {
        NSLog(@"该设备不支持蓝牙");
    }
    if (central.state==CBManagerStatePoweredOff) {
        NSLog(@"蓝牙已关闭");
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.name hasPrefix:@"MT"]) {
        [self.connectDeviceVC didDiscoverDevice];
        self.peripheral = peripheral;
        [central connectPeripheral:self.peripheral options:nil];
    }
}

//** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self.centralManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    self.receivedMessage  = @"";
    NSLog(@"连接成功");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.connectDeviceVC didConnectedDevice];
        self.connectView.hidden = true;
        self.finderView.hidden = false;
        [self.viewFinderVC startCameraSession];
        //[self writeMessageToBluno:-100];
        //[self writeMessageToBluno:-1];
    });
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败");
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"连接关闭");
    [self backToDeviceSelection];
}

#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBService *service = peripheral.services.lastObject;
    [peripheral discoverCharacteristics:nil forService:service];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    self.characteristic = service.characteristics.lastObject;
    [peripheral readValueForCharacteristic:self.characteristic];
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *currentCommand = @"";
    NSData *data = characteristic.value;
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (![NSString isEmpty:message]) {
        message = [[message trim] stringByReplacingOccurrencesOfString:@"#" withString:@""];
        DLog(@"Raw Message: %@", message);
        self.receivedMessage = [[self.receivedMessage stringByAppendingString:message] trim];
    }
    
    NSMutableArray *arr = [[self.receivedMessage componentsSeparatedByString:@";"] mutableCopy];
    [arr removeObject:@""];
    if ([arr count] > 0) {
        DLog(@"ReceivedMessageArray: %@", arr[0]);
        currentCommand = arr[0];
        [arr removeObjectAtIndex:0];
        self.receivedMessage = [arr componentsJoinedByString:@";"];
    }
    
    if (![currentCommand containsString:@"TB_END"]) {
        return;
    }
    switch (self.currentMessage) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.viewFinderVC doCaptureAction];
            });
            break;
        }
    }
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功");
}

 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	 if ([segue.identifier isEqualToString:@"Embed Connect"]) {
		 self.connectDeviceVC = (ConnectDeviceViewController*)segue.destinationViewController;
	 }
	 if ([segue.identifier isEqualToString:@"Embed Finder"]) {
		 self.viewFinderVC = (ViewFinderViewController*)segue.destinationViewController;
	 }
     if ([segue.identifier isEqualToString:@"Save Treatment"]) {
         SaveTreatmentViewController *vc = (SaveTreatmentViewController*)segue.destinationViewController;
         vc.isManualCapture = self.viewFinderVC.isTesting;
     }
 }

#pragma mark - Actions

- (IBAction)dismissAction:(id)sender {
    if (self.finderView.hidden) {
        [self showAlertWithTitle:@"Discard?" message:@"Discard current progress and back to agreement capture screen." cancelButtonTitle:@"Later" cancelHandler:nil destructiveTitle:@"Discard" destructiveHandler:^(UIAlertAction * _Nonnull action) {
            if (self.peripheral != nil) {
                [self.centralManager cancelPeripheralConnection:self.peripheral];
            }
            [self.navigationController popViewControllerAnimated:true];
            //[self dismissViewControllerAnimated:true completion:nil];
        }];
    } else {
        [self showAlertWithTitle:@"Discard?" message:@"Discard current progress and back to device selection screen." cancelButtonTitle:@"Later" cancelHandler:nil destructiveTitle:@"Discard" destructiveHandler:^(UIAlertAction * _Nonnull action) {
            if (self.peripheral != nil) {
                [self.centralManager cancelPeripheralConnection:self.peripheral];
            } else {
                [self backToDeviceSelection];
            }
        }];
    }
}

- (void)backToDeviceSelection {
    self.receivedMessage = @"";
    self.peripheral = nil;
    [self.viewFinderVC stopVideoSession];
    self.viewFinderVC.calltype=@"clear";
    [self.viewFinderVC stopCameraSession];
    [self.connectDeviceVC didDisconnectDevice];
    self.connectView.hidden = false;
    self.finderView.hidden = true;
    NSLog(@"Move back Now");
    
    [SVProgressHUD dismiss];
}

- (void)connectBluno {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)sendMessageToBluno:(NSString *)message {
    NSString *remainMessage = [message trim];
    NSLog(@"Sent: %@", remainMessage);
    while ([remainMessage length] > 0) {
        NSString *readyMessage = remainMessage;
        if ([remainMessage length] > 20) {
            readyMessage = [remainMessage substringToIndex:20];
        }
        remainMessage = [remainMessage substringFromIndex:[readyMessage length]];
        NSData *data = [readyMessage dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (BOOL)writeMessageToBluno:(int)message {
    if (self.peripheral) {
        self.currentMessage = message;
        NSString *txt = @"";
        switch (message) {
            case -100:
                txt = @"CT+HEARTBEAT(0);";
                break;
                
            case -1:
                txt = @"CT+TOZERO();";
                break;
                
            case 0:
                txt = @"CT+START(1,1,1,10,1,1);";
                break;
                
            case 1:
                txt = @"CT+START(1,1,1,45,1,1);";
                break;
                
            case 2:
            case 3:
                txt = @"CT+START(1,1,1,35,1,1);";
                break;
                
            case 4:
                txt = @"CT+START(1,1,1,45,1,1);";
                break;
                
            case 5:
                txt = @"CT+START(0,1,1,170,1,1);";
                break;
        }
        [self sendMessageToBluno:txt];
        
        return true;
    }
    return false;
}

- (IBAction)saveAction:(id)sender {
	// [self dismissViewControllerAnimated:true completion:nil];
    if (self.peripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    } else {
        [self backToDeviceSelection];
    }

	[self performSegueWithIdentifier:@"Save Treatment" sender:self];
//	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//	SaveTreatmentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"treatmentreport"];
//	[self presentViewController:vc animated:true completion:nil];
}

- (IBAction)playVideoAction:(id)sender {
	NSString *getPath = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:getPath]) {
		DLog(@"exist");
		DLog(@"Play video exist");
	} else {
		DLog(@"not exist");
		DLog(@"Play video not exist");
	}
	NSURL *videoURL = [NSURL fileURLWithPath:getPath];
	// create an AVPlayer
	AVPlayer *player = [AVPlayer playerWithURL:videoURL];
	// create a player view controller
	AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
	controller.player = player;
	[player play];
	[self presentViewController:controller animated:true completion:nil];
	controller.view.frame = self.view.frame;
	[controller.player play];
}


- (void) dealloc
{
    DLog(@"Capture View controller dealloc process");

}



@end
