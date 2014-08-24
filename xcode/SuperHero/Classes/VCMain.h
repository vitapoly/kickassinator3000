//
//  VCMain.h
//  BlunoTest
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFBlunoManager.h"
#import "SpeechToTextModule.h"


@interface VCMain : UIViewController<DFBlunoDelegate, AVSpeechSynthesizerDelegate, SpeechToTextModuleDelegate>{
    BOOL recognizingSpeech;
}

@property(strong, nonatomic) DFBlunoManager* blunoManager;
@property(strong, nonatomic) DFBlunoDevice* blunoDev;
@property(strong, nonatomic) NSMutableArray* aryDevices;

@property (weak, nonatomic) IBOutlet UILabel *lbReceivedMsg;
@property (weak, nonatomic) IBOutlet UITextField *txtSendMsg;
@property (weak, nonatomic) IBOutlet UILabel *lbReady;

@property (strong, nonatomic) IBOutlet UIView *viewDevices;
@property (weak, nonatomic) IBOutlet UITableView *tbDevices;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *SearchIndicator;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDevices;

@property (weak, nonatomic) IBOutlet UIImageView *body;
@property (weak, nonatomic) IBOutlet UIImageView *boosters;
@property (weak, nonatomic) IBOutlet UIImageView *magnet;
@property (weak, nonatomic) IBOutlet UIImageView *laser;
@property (weak, nonatomic) IBOutlet UIImageView *irCam;
@property (weak, nonatomic) IBOutlet UIImageView *motion;
@property (weak, nonatomic) IBOutlet UIImageView *lights;

@property (weak, nonatomic) IBOutlet UIWebView *webView;


- (IBAction)actionReturn:(id)sender;
- (IBAction)actionSend:(id)sender;
- (IBAction)actionDidEnd:(id)sender;

@property(strong, nonatomic) AVSpeechSynthesizer* speechSyn;

@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;

-(void)start;

-(IBAction)connectBT:(id)sender;
-(void)sendBT:(NSString *)msg;
-(void)receiveBT:(NSString *)msg;

-(void)sendIP:(NSString *)msg;
-(void)receiveIP:(NSString *)msg;

-(void)speak:(NSString *)msg;
-(void)startSpeechRecognition;
-(void)stopSpeechRecognition;



@end
